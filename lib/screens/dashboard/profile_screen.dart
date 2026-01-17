import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import 'home_screen.dart'; // Import to access ScheduleTask model

class ProfileScreen extends StatelessWidget {
  final List<ScheduleTask> tasks;

  const ProfileScreen({super.key, required this.tasks});

  // --- HELPER: Calculate Stats ---
  Map<String, String> _calculateStats() {
    int total = 0;
    int completed = 0;
    int studyMinutes = 0;

    final now = DateTime.now();
    final timeNow = TimeOfDay.now();
    final currentMinutes = timeNow.hour * 60 + timeNow.minute;

    for (var task in tasks) {
      if (task.status == TaskStatus.scheduled) {
        total++;
        
        // Parse Time
        final endParts = task.endTime.split(':').map(int.parse).toList();
        final startParts = task.time.split(':').map(int.parse).toList();
        final endTaskMinutes = endParts[0] * 60 + endParts[1];
        
        // Calculate Duration
        int duration = endTaskMinutes - (startParts[0] * 60 + startParts[1]);
        studyMinutes += duration;

        // Check if "Completed" (Time has passed)
        // Note: Simple logic assuming tasks are for "Today". 
        // For a full app, you'd check dates too.
        if (endTaskMinutes < currentMinutes) {
          completed++;
        }
      }
    }

    // Completion %
    double progress = total == 0 ? 0 : (completed / total);

    return {
      "total": total.toString(),
      "completed": completed.toString(),
      "hours": (studyMinutes / 60).toStringAsFixed(1),
      "progress": progress.toString(), // 0.0 to 1.0
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "Guest User";
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = _calculateStats();
    final double progressVal = double.parse(stats["progress"]!);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.goldAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- 1. PROFILE HEADER ---
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.goldAccent.withOpacity(0.2),
                    child: Text(
                      email[0].toUpperCase(),
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.darkBlue
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Level 1 Scholar", // Gamification placeholder
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- 2. PROGRESS BAR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Progress", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${(progressVal * 100).toInt()}%", style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressVal,
                minHeight: 10,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                color: AppTheme.goldAccent,
              ),
            ),

            const SizedBox(height: 30),

            // --- 3. STATS CARDS ---
            Row(
              children: [
                _buildStatCard(context, "Tasks Done", stats["completed"]!, Icons.check_circle, Colors.green),
                const SizedBox(width: 16),
                _buildStatCard(context, "Study Hours", "${stats['hours']}h", Icons.timer, Colors.blue),
              ],
            ),

            const SizedBox(height: 30),

            // --- 4. RECENT ACTIVITY ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Scheduled Tasks", 
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.darkBlue
                )
              ),
            ),
            const SizedBox(height: 16),
            
            // List of actual tasks
            ...tasks.where((t) => t.status == TaskStatus.scheduled).map((task) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, size: 18, color: AppTheme.goldAccent),
                  title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  subtitle: Text("${task.time} - ${task.endTime}"),
                  trailing: Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(color: AppTheme.goldAccent, shape: BoxShape.circle),
                  ),
                ),
              );
            }),
            
            if (tasks.where((t) => t.status == TaskStatus.scheduled).isEmpty)
               const Padding(
                 padding: EdgeInsets.all(20.0),
                 child: Text("No tasks scheduled yet. Start planning!", style: TextStyle(color: Colors.grey)),
               )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
