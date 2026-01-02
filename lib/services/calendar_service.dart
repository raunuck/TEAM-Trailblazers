import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:intl/intl.dart';

class CalendarService {
  // TASK 1: Google Calendar API Connection
  // We define the specific permission (scope) we need: Read-Only access.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [cal.CalendarApi.calendarEventsReadonlyScope],
  );

  // TASK 2: Build Calendar Permission Flow & TASK 3: Import Logic
  Future<List<Map<String, dynamic>>?> fetchCalendarEvents() async {
    try {
      // A. Trigger the popup. If the user hasn't signed in, this asks for permissions.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If user cancels the popup, return null
      if (googleUser == null) return null;

      // B. Authenticate via HTTP Client
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return null;

      // C. Connect to the API
      final calendarApi = cal.CalendarApi(httpClient);

      // D. Define "Today's" range (Midnight to Midnight)
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toUtc();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59).toUtc();

      // E. Fetch the events
      final events = await calendarApi.events.list(
        "primary", // The main calendar
        timeMin: startOfDay,
        timeMax: endOfDay,
        singleEvents: true, // Expand recurring events (like weekly classes)
        orderBy: 'startTime',
      );

      // TASK 4: Parse Events into App Format
      return _parseAndAdaptiveGapLogic(events.items ?? []);

    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }

  // TASK 4 (Continued): Parsing & Smart Gap Detection
  List<Map<String, dynamic>> _parseAndAdaptiveGapLogic(List<cal.Event> googleEvents) {
    List<Map<String, dynamic>> appSchedule = [];
    final timeFormat = DateFormat("HH:mm");

    // 1. Convert Google Events to App Cards
    for (var event in googleEvents) {
      if (event.start?.dateTime == null || event.end?.dateTime == null) continue;

      final startTime = event.start!.dateTime!.toLocal();
      final endTime = event.end!.dateTime!.toLocal();
      
      appSchedule.add({
        "time": timeFormat.format(startTime),
        "endTime": timeFormat.format(endTime), // Used for duration calc
        "title": event.summary ?? "Untitled Class",
        "location": event.location ?? "Campus",
        "type": "class",
        "status": "active",
        "rawStart": startTime, // Helper for sorting
        "rawEnd": endTime,     // Helper for gap detection
      });
    }

    // 2. ADAPTIVE LOGIC: Find gaps between classes
    if (appSchedule.isEmpty) return [];
    
    List<Map<String, dynamic>> finalSchedule = [];
    
    for (int i = 0; i < appSchedule.length; i++) {
      finalSchedule.add(appSchedule[i]);

      // Look ahead to the next event
      if (i < appSchedule.length - 1) {
        DateTime currentEnd = appSchedule[i]['rawEnd'];
        DateTime nextStart = appSchedule[i + 1]['rawStart'];
        
        // Calculate difference in minutes
        int gapMinutes = nextStart.difference(currentEnd).inMinutes;

        // If gap is useful (e.g., > 15 mins), insert a "Smart Gap Card"
        if (gapMinutes >= 15) {
          finalSchedule.add({
            "time": timeFormat.format(currentEnd),
            "endTime": "${gapMinutes}m", // Store duration like "45m"
            "title": "Free Slot Detected",
            "type": "gap", // This triggers the SmartGapCard UI
            "suggestion": "Review notes from ${appSchedule[i]['title']}",
          });
        }
      }
    }

    return finalSchedule;
  }
}