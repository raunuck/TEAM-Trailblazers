import 'dart:developer';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:intl/intl.dart';
import '../screens/dashboard/home_screen.dart'; 

class CalendarService {
  // --- MISSING VARIABLE FIX ---
  // This was missing in your previous file
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [cal.CalendarApi.calendarEventsReadonlyScope],
  );

  Future<List<ScheduleTask>?> fetchCalendarEvents(DateTime date) async {
    try {
      print("DEBUG: Starting Sign In Flow...");

      // 1. Silent Sign In (Try to log in without popup first)
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      
      // 2. If silent fails, trigger the popup
      if (googleUser == null) {
        print("DEBUG: Silent sign-in failed, attempting interactive sign-in...");
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        print("DEBUG: User cancelled the sign-in popup.");
        return null;
      }

      print("DEBUG: Sign In Successful for: ${googleUser.email}");

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        print("DEBUG: Failed to authenticate HTTP client");
        return null;
      }

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

      print("DEBUG: Fetched ${events.items?.length ?? 0} events from Google.");

      return _parseAndAdaptiveGapLogic(events.items ?? []);
    } catch (e, stackTrace) {
      // THIS WILL SHOW THE REAL ERROR IN YOUR CONSOLE
      print("CRITICAL CALENDAR ERROR: $e");
      print("STACK TRACE: $stackTrace");
      return null;
    }
  }

  List<ScheduleTask> _parseAndAdaptiveGapLogic(List<cal.Event> googleEvents) {
    List<ScheduleTask> appSchedule = [];
    final timeFormat = DateFormat("HH:mm");

    // 1. Convert Google Events to ScheduleTasks
    for (var event in googleEvents) {
      if (event.start?.dateTime == null || event.end?.dateTime == null) continue;

      final startTime = event.start!.dateTime!.toLocal();
      final endTime = event.end!.dateTime!.toLocal();
      
      appSchedule.add(ScheduleTask(
        id: event.id ?? DateTime.now().toString(),
        time: timeFormat.format(startTime),
        endTime: timeFormat.format(endTime),
        title: event.summary ?? "Untitled Class",
        location: event.location ?? "Campus",
        status: TaskStatus.scheduled,
      ));
    }

    // 2. Adaptive Gap Logic (Insert Free Slots)
    if (appSchedule.isEmpty) return [];
    
    List<ScheduleTask> finalSchedule = [];
    
    for (int i = 0; i < appSchedule.length; i++) {
      finalSchedule.add(appSchedule[i]);

      if (i < appSchedule.length - 1) {
        // Parse back the times to calculate difference
        DateTime currentEnd = _parseTime(appSchedule[i].endTime);
        DateTime nextStart = _parseTime(appSchedule[i + 1].time);
        
        int gapMinutes = nextStart.difference(currentEnd).inMinutes;

        // If gap is significant (e.g., > 15 mins), insert a Free Slot
        if (gapMinutes >= 15) {
          finalSchedule.add(ScheduleTask(
            id: "gap_$i",
            time: timeFormat.format(currentEnd),
            endTime: timeFormat.format(nextStart),
            title: "Free Slot Detected",
            status: TaskStatus.free,
            description: "Gap of ${gapMinutes}m available for Deep Work",
          ));
        }
      }
    }
    return finalSchedule;
  }

  // Helper to parse HH:mm back to DateTime for calculation
  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(":");
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }
}