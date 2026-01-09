import 'dart:math';

class AIService {
  static int _parseDurationToMinutes(String durationStr) {
    int minutes = 0;
    
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
    
    return minutes > 0 ? minutes : 30; 
  }

  static Future<String> generateSmartTask({
    required String duration,
    required List<String> interests,
    required String academicSubject,
  }) async {
    
    await Future.delayed(const Duration(seconds: 2));

    int totalMinutes = _parseDurationToMinutes(duration);
    final random = Random();
    String interest = interests.isNotEmpty 
        ? interests[random.nextInt(interests.length)] 
        : "Skill Development";

    
    if (totalMinutes <= 30) {
      return "⚡ **Quick Sprint ($totalMinutes min):**\n"
          "• 5 min: Review notes from $academicSubject.\n"
          "• ${totalMinutes - 5} min: Watch a short explanation video on '$interest'.";
    } 
    
    else if (totalMinutes <= 60) {
      int deepWork = totalMinutes - 10;
      return "⏱️ **Focus Session ($totalMinutes min):**\n"
          "• 5 min: Setup & Goal setting.\n"
          "• $deepWork min: Deep dive into '$interest' (Tutorial or Article).\n"
          "• 5 min: Quick summary of what you learned.";
    } 
    
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