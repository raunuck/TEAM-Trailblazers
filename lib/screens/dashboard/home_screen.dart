import 'package:flutter/material.dart';
import '../../core/theme.dart'; // Adjust path if needed
import '../vault/vault_screen.dart';
import '../../services/ai_service.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- MOCK DATA (Simulating Google Calendar) ---
  final List<Map<String, dynamic>> _schedule = [
    {
      "time": "09:00",
      "endTime": "10:30",
      "title": "Computer Architecture",
      "location": "Room 304",
      "type": "class",
      "status": "active", // active, cancelled, completed
    },
    {
      "time": "10:30",
      "endTime": "11:30",
      "title": "Free Slot detected!",
      "location": "Anywhere",
      "type": "gap", // This is the "Opportunity"
      "suggestion": "Review Pipelining Logic", // Based on your COA interest
    },
    {
      "time": "11:30",
      "endTime": "12:30",
      "title": "Database Systems",
      "location": "Lab 2",
      "type": "class",
      "status": "active",
    },
    {
      "time": "01:30",
      "endTime": "02:30",
      "title": "Mathematics IV",
      "location": "Room 101",
      "type": "class",
      "status": "cancelled", // We will style this differently
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      
      // Top Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Schedule",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
            Text(
              "Wed, 31 Dec • 2 Free Slots",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          // User Avatar (Placeholder)
          const CircleAvatar(
            backgroundColor: AppTheme.primaryBlue,
            radius: 18,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),

      // The Timeline List
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _schedule.length,
        itemBuilder: (context, index) {
          final item = _schedule[index];
          
          // Determine which card to show
          if (item['type'] == 'gap') {
            return SmartGapCard(item: item);
          } else {
            return _buildClassCard(item);
          }
        },
      ),
      
      // Floating Action Button for "Vault" (Ideas)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Vault Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VaultScreen()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- WIDGET 1: The Standard Class Card ---
  Widget _buildClassCard(Map<String, dynamic> item) {
    bool isCancelled = item['status'] == 'cancelled';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Column
            SizedBox(
              width: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['time'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['endTime'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            // Vertical Line
            Container(
              width: 2,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),

            // Card Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCancelled ? Colors.red.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCancelled ? Colors.red.shade100 : Colors.transparent,
                  ),
                  boxShadow: isCancelled ? [] : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: isCancelled ? TextDecoration.lineThrough : null,
                            color: isCancelled ? Colors.red : Colors.black87,
                          ),
                        ),
                        if (isCancelled)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "CANCELLED",
                              style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(item['location'], style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET 2: The "Gap" / Opportunity Card ---
  Widget _buildGapCard(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Column
            SizedBox(
              width: 50,
              child: Text(
                item['time'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.growthGreen),
              ),
            ),
            
            // Vertical Dashed Line (Visual trick using Container for now)
            Container(
              width: 2,
              color: AppTheme.growthGreen.withValues(alpha: 0.3),
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),

            // Opportunity Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.growthGreen.withValues(alpha: 0.1), 
                      Colors.white
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.growthGreen.withValues(alpha:0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Free Time Detected!",
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Suggestion: ${item['suggestion']}",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          // Start Activity Logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.growthGreen,
                          elevation: 0,
                          side: const BorderSide(color: AppTheme.growthGreen),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text("Start Activity"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SmartGapCard extends StatefulWidget {
  final Map<String, dynamic> item;
  
  const SmartGapCard({super.key, required this.item});

  @override
  State<SmartGapCard> createState() => _SmartGapCardState();
}

class _SmartGapCardState extends State<SmartGapCard> {
  String? _aiSuggestion; // Stores the generated plan
  bool _isLoading = false; // Controls the loading spinner

  void _askAI() async {
    setState(() {
      _isLoading = true;
    });

    // 1. Calculate Duration
    // In a real app, calculate this from start/end times. 
    // For this mock, we check if the end time suggests a long break.
    String mockDuration = widget.item['endTime'] == "11:30" ? "1h 30m" : "45m"; 

    // 2. Call the AI Service
    String result = await AIService.generateSmartTask(
      duration: mockDuration, 
      interests: ["Flutter Dev", "AI Tools", "Public Speaking"], // This would come from user profile
      academicSubject: "Computer Architecture", // Context from the previous class
    );

    // 3. Update UI
    setState(() {
      _aiSuggestion = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- LEFT COLUMN: TIME ---
            SizedBox(
              width: 50,
              child: Text(
                widget.item['time'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, 
                  color: Color(0xFF10B981) // Growth Green
                ),
              ),
            ),
            
            // --- CENTER: DASHED LINE ---
            Container(
              width: 2,
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),

            // --- RIGHT COLUMN: THE CARD ---
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF10B981).withValues(alpha: 0.1), 
                      Colors.white
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3)
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Free Slot Detected",
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // --- DYNAMIC CONTENT AREA ---
                    if (_isLoading)
                      // STATE 1: LOADING
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2)
                            ),
                            SizedBox(width: 12),
                            Text("Designing your schedule...", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    else if (_aiSuggestion != null)
                      // STATE 2: SHOW RESULT
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Text(
                          _aiSuggestion!,
                          style: const TextStyle(
                            fontSize: 14, 
                            height: 1.6, // Nice spacing for the plan
                            color: Colors.black87,
                          ),
                        ),
                      )
                    else
                      // STATE 3: INITIAL PROMPT
                      const Text(
                        "You have free time available. Tap below to generate a productivity plan based on your interests.",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),

                    const SizedBox(height: 12),
                    
                    // --- BUTTON ---
                    if (_aiSuggestion == null && !_isLoading)
                      ElevatedButton.icon(
                        onPressed: _askAI,
                        icon: const Icon(Icons.bolt, size: 18),
                        label: const Text("Generate Smart Plan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF10B981),
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFF10B981)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}