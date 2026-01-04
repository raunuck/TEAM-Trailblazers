import 'package:flutter/material.dart';
import '../../core/theme.dart';

// --- 1. Model for Dummy Data ---
class LeaderboardEntry {
  final String name;
  final int rank;
  final int points;
  final int tasksCompleted;
  final String department; // e.g., CSE, ECE

  const LeaderboardEntry({
    required this.name,
    required this.rank,
    required this.points,
    required this.tasksCompleted,
    required this.department,
  });
}

// --- 2. Dummy Data (Students completing tasks) ---
final List<LeaderboardEntry> _leaderboardData = [
  const LeaderboardEntry(name: "Priya Sharma", rank: 1, points: 2450, tasksCompleted: 42, department: "CSE"),
  const LeaderboardEntry(name: "Rahul Verma", rank: 2, points: 2300, tasksCompleted: 38, department: "ECE"),
  const LeaderboardEntry(name: "Amit Patel", rank: 3, points: 2150, tasksCompleted: 35, department: "MECH"),
  const LeaderboardEntry(name: "Sneha Gupta", rank: 4, points: 1900, tasksCompleted: 30, department: "CSE"),
  const LeaderboardEntry(name: "Vikram Singh", rank: 5, points: 1850, tasksCompleted: 28, department: "CIVIL"),
  const LeaderboardEntry(name: "Ananya Roy", rank: 6, points: 1700, tasksCompleted: 25, department: "BIO"),
  const LeaderboardEntry(name: "David John", rank: 7, points: 1650, tasksCompleted: 24, department: "CSE"),
  const LeaderboardEntry(name: "Kavita Das", rank: 8, points: 1500, tasksCompleted: 20, department: "EEE"),
  const LeaderboardEntry(name: "Meera Reddy", rank: 9, points: 1200, tasksCompleted: 15, department: "IT"),
  const LeaderboardEntry(name: "Rohan Kumar", rank: 10, points: 900, tasksCompleted: 10, department: "CSE"),
];

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.darkBlue;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    // Split data into Top 3 and Rest
    // We expect at least 3 users for the podium to work perfectly
    final topThree = _leaderboardData.take(3).toList();
    final restOfTheList = _leaderboardData.skip(3).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Leaderboard", 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          // --- TOP 3 PODIUM SECTION ---
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end, // Align bottom
              children: [
                // Rank 2 (Left)
                _buildPodiumPosition(context, topThree[1], 140, Colors.grey.shade400),
                
                // Rank 1 (Center - Biggest)
                _buildPodiumPosition(context, topThree[0], 170, Colors.amber),
                
                // Rank 3 (Right)
                _buildPodiumPosition(context, topThree[2], 120, Colors.brown.shade300),
              ],
            ),
          ),

          // --- THE REST OF THE LIST ---
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))
                ]
              ),
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                itemCount: restOfTheList.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = restOfTheList[index];
                  return _buildListItem(context, entry, isDark);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Build one pillar of the podium
  Widget _buildPodiumPosition(BuildContext context, LeaderboardEntry entry, double height, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.darkBlue;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              entry.name[0], 
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)
            ),
          ),
          const SizedBox(height: 8),
          
          // Name and Points
          Text(
            entry.name.split(" ")[0], // First name only
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "${entry.points} pts", 
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11)
          ),
          const SizedBox(height: 8),

          // The Pillar
          Container(
            height: height,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.3 : 0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              "#${entry.rank}",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: color
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Build a standard list row
  Widget _buildListItem(BuildContext context, LeaderboardEntry entry, bool isDark) {
    final textColor = isDark ? Colors.white : AppTheme.darkBlue;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 40,
            child: Text(
              "#${entry.rank}", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Avatar
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Text(entry.name[0], style: const TextStyle(color: Colors.blue)),
          ),
          const SizedBox(width: 16),
          
          // Name & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name, 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)
                ),
                Text(
                  "${entry.department} • ${entry.tasksCompleted} Tasks Done", 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)
                ),
              ],
            ),
          ),
          
          // Points Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${entry.points}", 
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)
            ),
          )
        ],
      ),
    );
  }
}