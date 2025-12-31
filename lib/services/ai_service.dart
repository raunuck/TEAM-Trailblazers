import 'dart:math';

class AIService {
  // Helper to parse "1h 30m" or "45m" into integer minutes
  static int _parseDurationToMinutes(String durationStr) {
    int minutes = 0;
    
    // Simple regex to find hours and minutes
    final hourRegex = RegExp(r'(\d+)h');
    final minRegex = RegExp(r'(\d+)m');

    final hourMatch = hourRegex.firstMatch(durationStr);
    final minMatch = minRegex.firstMatch(durationStr);

    if (hourMatch != null) {
      minutes += int.parse(hourMatch.group(1)!) * 60;
    }
    if (minMatch != null) {
      minutes += int.parse(minMatch.group(1)!);
    }
    
    // Default to 30 mins if parsing fails
    return minutes > 0 ? minutes : 30; 
  }

  static Future<String> generateSmartTask({
    required String duration, // e.g., "1h 30m"
    required List<String> interests,
    required String academicSubject, // e.g., "Data Structures"
  }) async {
    
    await Future.delayed(const Duration(seconds: 2)); // Simulate AI thinking

    int totalMinutes = _parseDurationToMinutes(duration);
    final random = Random();
    String interest = interests.isNotEmpty 
        ? interests[random.nextInt(interests.length)] 
        : "Skill Development";

    // --- LOGIC: TIME-BLOCKING STRATEGY ---
    
    // SCENARIO 1: SHORT SPRINT (< 30 mins)
    if (totalMinutes <= 30) {
      return "⚡ **Quick Sprint ($totalMinutes min):**\n"
          "• 5 min: Review notes from $academicSubject.\n"
          "• ${totalMinutes - 5} min: Watch a short explanation video on '$interest'.";
    } 
    
    // SCENARIO 2: POMODORO SESSION (30 - 60 mins)
    else if (totalMinutes <= 60) {
      int deepWork = totalMinutes - 10; // Reserve 10 mins for planning/review
      return "⏱️ **Focus Session ($totalMinutes min):**\n"
          "• 5 min: Setup & Goal setting.\n"
          "• $deepWork min: Deep dive into '$interest' (Tutorial or Article).\n"
          "• 5 min: Quick summary of what you learned.";
    } 
    
    // SCENARIO 3: DEEP WORK BLOCK (> 60 mins)
    else {
      int block1 = (totalMinutes * 0.4).round();
      int block2 = (totalMinutes * 0.4).round();
      int breakTime = totalMinutes - block1 - block2;

      return "🧠 **Deep Work Block ($totalMinutes min):**\n"
          "• $block1 min: Academic Revision ($academicSubject) - Solve 2 problems.\n"
          "• $breakTime min: ☕ Coffee Break / Walk.\n"
          "• $block2 min: Personal Project - Work on your '$interest' prototype.";
    }
  }
}