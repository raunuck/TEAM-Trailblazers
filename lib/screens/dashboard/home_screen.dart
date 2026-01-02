import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme.dart';
import '../../services/ai_service.dart';
import '../../services/calendar_service.dart';

class SmartGapCard extends StatefulWidget {
  final Map<String, dynamic> item;
  
  const SmartGapCard({super.key, required this.item});

  @override
  State<SmartGapCard> createState() => _SmartGapCardState();
}

class _SmartGapCardState extends State<SmartGapCard> {
  String? _aiSuggestion;
  bool _isLoading = false;

  void _askAI() async {
    setState(() {
      _isLoading = true;
    });

    String mockDuration = widget.item['endTime'] == "11:30" ? "1h 30m" : "45m"; 

    // 2. Call the AI Service
    String result = await AIService.generateSmartTask(
      duration: mockDuration, 
      interests: ["Flutter Dev", "AI Tools", "Public Speaking"],
      academicSubject: "Computer Architecture",
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
      // Removing IntrinsicHeight helps avoid the pixel overflow error
      // The row will naturally grow to fit the tallest item (the text card)
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
          // We wrap this in a Container with a fixed height or let it follow the parent
          // Without IntrinsicHeight, we use a custom approach or just a small marker
          Container(
            width: 2,
            height: 100, // Fixed height ensures no crash, or remove height to let it shrink
            color: const Color(0xFF10B981).withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),

          // --- RIGHT COLUMN: THE CARD ---
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.1), 
                    Colors.white
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3)
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // <--- CRITICAL FIX
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text("Designing your schedule...", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  else if (_aiSuggestion != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Using SelectableText allows scrolling if it gets REALLY long
                      child: Text(
                        _aiSuggestion!.replaceAll("**", ""), // Clean up the asterisks
                        style: const TextStyle(
                          fontSize: 14, 
                          height: 1.5, 
                          color: Colors.black87,
                        ),
                      ),
                    )
                  else
                    const Text(
                      "You have free time available. Tap below to generate a productivity plan.",
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
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSyncing = false;
  // Add this variable at the top of _HomeScreenState
  final CalendarService _calendarService = CalendarService(); 

  Future<void> _syncCalendar() async {
    setState(() => _isSyncing = true);

    try {
      final fetchedEvents = await _calendarService.fetchCalendarEvents();

      if (fetchedEvents != null) {
        setState(() {
          _schedule.clear(); // Remove the mock/fake data
          _schedule.addAll(fetchedEvents); // Add real Google data
        });
        
        if (fetchedEvents.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sync successful, but no events found for today.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sync Complete! Schedule updated.")),
          );
        }
      } 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sync failed: $e")),
      );
    } finally {
      setState(() => _isSyncing = false);
    }
  }
  CalendarFormat _calendarFormat = CalendarFormat.week; // Defaults to Week view
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock Schedule Data (In real app, fetch from Google API based on _selectedDay)
  final List<Map<String, dynamic>> _schedule = [
    {"time": "09:00", "endTime": "10:30", "title": "Computer Architecture", "type": "class", "status": "active"},
    {"time": "10:30", "endTime": "11:30", "title": "Free Slot", "type": "gap", "suggestion": "Review Pipelining"},
    {"time": "11:30", "endTime": "12:30", "title": "Database Systems", "type": "class", "status": "active"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.sync), onPressed: () {
            // TODO: Trigger Google Calendar Sync
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Syncing with Google Calendar...")));
          }),
        ],
      ),
      body: Column(
        children: [
          // 1. THE GOOGLE CALENDAR UI STRIP
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 10),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              
              // Style it to look like Google Calendar
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
              ),

              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; 
                  // Here is where you would fetch new events for the selected day
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format; // Switch between Week / 2 Weeks / Month
                });
              },
            ),
          ),

          const Divider(height: 1),

          // 2. THE TIMELINE LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _schedule.length,
              itemBuilder: (context, index) {
                final item = _schedule[index];
                if (item['type'] == 'gap') {
                  return SmartGapCard(item: item); // Uses the AI card we built
                } else {
                  return _buildClassCard(item);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // (Include _buildClassCard code here from previous steps)
  Widget _buildClassCard(Map<String, dynamic> item) {
    // ... Copy the code from the previous HomeScreen ...
    return Container(
      padding: const EdgeInsets.all(16), 
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white, 
      child: Text(item['title'])
    ); // Placeholder for brevity
  }
}