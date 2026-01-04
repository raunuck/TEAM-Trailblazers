import 'package:flutter/material.dart';
import '../../core/theme.dart'; // Keeping your import, but using standard colors below for portability

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Theme Awareness Logic
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Define colors based on theme
    final Color scaffoldBg = isDark ? const Color(0xFF121212) : Colors.grey.shade50;
    final Color appBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryText = isDark ? Colors.white : const Color(0xFF222222); // Replaces AppTheme.darkBlue
    final Color accentColor = Colors.blueAccent; // Replaces AppTheme.primaryBlue

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Campus Community", 
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: appBarBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent, // Removes the slight wash in Material 3
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: primaryText),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Logic to "Propose an Activity"
        },
        label: const Text("Start Activity", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: accentColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Happening Now", 
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: primaryText
            )
          ),
          const SizedBox(height: 10),
          
          // 2. Rendering the Dummy Data using a generator
          ..._dummyActivities.map((activity) => _buildActivityCard(
            context: context,
            activity: activity,
            isDark: isDark,
          )),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required BuildContext context,
    required Activity activity,
    required bool isDark,
  }) {
    // Color Logic specific to cards
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : const Color(0xFF222222);
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Card(
      elevation: 0,
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tags Row
                Row(
                  children: activity.tags.map((t) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      // Adaptive Tag Colors
                      color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6)
                    ),
                    child: Text(
                      t, 
                      style: TextStyle(
                        fontSize: 10, 
                        color: isDark ? Colors.blue.shade200 : Colors.blue.shade800, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  )).toList(),
                ),
                Text(
                  activity.timeLeft, 
                  style: TextStyle(
                    color: Colors.orange.shade700, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12
                  )
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activity.title, 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: textColor
              )
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: subTextColor),
                const SizedBox(width: 4),
                Text(
                  activity.location, 
                  style: TextStyle(color: subTextColor)
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: subTextColor),
                    const SizedBox(width: 4),
                    Text(
                      "${activity.participants} joined", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: textColor
                      )
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {}, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Join"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Data Model & Dummy Data
// ---------------------------------------------------------------------------

class Activity {
  final String title;
  final String location;
  final int participants;
  final String timeLeft;
  final List<String> tags;

  const Activity({
    required this.title,
    required this.location,
    required this.participants,
    required this.timeLeft,
    required this.tags,
  });
}

final List<Activity> _dummyActivities = [
  const Activity(
    title: "Flutter Study Group",
    location: "Library Discussion Room",
    participants: 4,
    timeLeft: "Starts in 15 min",
    tags: ["Tech", "Code"],
  ),
  const Activity(
    title: "Impromptu Debate: AI Ethics",
    location: "Cafeteria",
    participants: 7,
    timeLeft: "Active Now",
    tags: ["Debate", "Social"],
  ),
  const Activity(
    title: "Basketball 3v3 Match",
    location: "Sports Complex Court A",
    participants: 5,
    timeLeft: "Starts in 1 hr",
    tags: ["Sports", "Fitness"],
  ),
  const Activity(
    title: "Midnight Gaming: Valorant",
    location: "Hostel Block B Common Room",
    participants: 9,
    timeLeft: "Tonight 10 PM",
    tags: ["Gaming", "Fun"],
  ),
  const Activity(
    title: "Hackathon Brainstorming",
    location: "Tech Park Lobby",
    participants: 3,
    timeLeft: "Active Now",
    tags: ["Innovation", "Ideas"],
  ),
];