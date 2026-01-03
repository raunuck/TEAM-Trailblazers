import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:intl/intl.dart';

class CalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [cal.CalendarApi.calendarEventsReadonlyScope],
  );

  Future<List<Map<String, dynamic>>?> fetchCalendarEvents(DateTime date) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return null;

      final calendarApi = cal.CalendarApi(httpClient);

      // Define Range (Midnight to Midnight of selected date)
      final startOfDay = DateTime(date.year, date.month, date.day).toUtc();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59).toUtc();

      final events = await calendarApi.events.list(
        "primary",
        timeMin: startOfDay,
        timeMax: endOfDay,
        singleEvents: true,
        orderBy: 'startTime',
      );

      return _parseAndAdaptiveGapLogic(events.items ?? []);
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }

  List<Map<String, dynamic>> _parseAndAdaptiveGapLogic(List<cal.Event> googleEvents) {
    List<Map<String, dynamic>> appSchedule = [];
    final timeFormat = DateFormat("HH:mm");

    for (var event in googleEvents) {
      if (event.start?.dateTime == null || event.end?.dateTime == null) continue;

      final startTime = event.start!.dateTime!.toLocal();
      final endTime = event.end!.dateTime!.toLocal();
      
      appSchedule.add({
        "time": timeFormat.format(startTime),
        "endTime": timeFormat.format(endTime),
        "title": event.summary ?? "Untitled Class",
        "location": event.location ?? "Campus",
        "type": "class",
        "rawStart": startTime,
        "rawEnd": endTime,
      });
    }

    // Adaptive Gap Logic
    if (appSchedule.isEmpty) return [];
    List<Map<String, dynamic>> finalSchedule = [];
    
    for (int i = 0; i < appSchedule.length; i++) {
      finalSchedule.add(appSchedule[i]);

      if (i < appSchedule.length - 1) {
        DateTime currentEnd = appSchedule[i]['rawEnd'];
        DateTime nextStart = appSchedule[i + 1]['rawStart'];
        
        int gapMinutes = nextStart.difference(currentEnd).inMinutes;

        if (gapMinutes >= 15) {
          finalSchedule.add({
            "time": timeFormat.format(currentEnd),
            "endTime": "${gapMinutes}m", 
            "title": "Free Slot Detected",
            "type": "gap",
            "suggestion": "Deep Work Block",
          });
        }
      }
    }
    return finalSchedule;
  }
}