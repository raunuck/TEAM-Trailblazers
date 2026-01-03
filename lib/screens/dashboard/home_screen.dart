import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme.dart';
import '../../services/calendar_service.dart';

// ==========================================
// 1. SMART GAP CARD WIDGET
// ==========================================
class SmartGapCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const SmartGapCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final innerBlockColor = isDark ? const Color(0xFF2A325E) : const Color(0xFFFCEFD0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: textColor, size: 20),
              const SizedBox(width: 8),
              Text("Free Slot Detected", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(width: 8),
              Icon(Icons.hive, color: textColor, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.psychology, color: AppTheme.goldAccent, size: 32),
              const SizedBox(width: 12),
              Text("Deep Work Block", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 24)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildTimelineBlock(color: innerBlockColor, textColor: textColor, icon: Icons.laptop_mac, time: "36 min", title: "Study")),
              Container(
                height: 80, 
                alignment: Alignment.center, 
                width: 30, 
                child: Icon(Icons.more_horiz, color: AppTheme.goldAccent.withOpacity(0.5))
              ),
              Expanded(flex: 3, child: _buildTimelineBlock(color: innerBlockColor, textColor: textColor, icon: Icons.campaign, time: "36 min", title: "Project")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineBlock({required Color color, required Color textColor, required IconData icon, required String time, required String title}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, size: 24, color: textColor),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}

// ==========================================
// 2. HOME SCREEN PAGE
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSyncing = false;
  final CalendarService _calendarService = CalendarService();
  
  // Calendar State
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week; // We use Week view for space

  // Mock Data (Overwritten by Sync)
  final List<Map<String, dynamic>> _schedule = [
    {"time": "09:00", "endTime": "10:30", "title": "Computer Arch", "type": "class", "location": "Lab 3"},
    {"time": "10:30", "endTime": "11:30", "title": "Free Slot", "type": "gap"},
    {"time": "11:30", "endTime": "12:30", "title": "Database Sys", "type": "class", "location": "Room 404"},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Future<void> _syncCalendar() async {
    setState(() => _isSyncing = true);
    try {
      final fetchedEvents = await _calendarService.fetchCalendarEvents(_selectedDay ?? DateTime.now());
      if (fetchedEvents != null) {
        setState(() {
          _schedule.clear();
          _schedule.addAll(fetchedEvents);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sync Complete!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sync failed: $e")));
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text("PlanBEE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSyncing ? Icons.hourglass_top : Icons.sync),
            onPressed: _syncCalendar,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- RESTORED CALENDAR WIDGET ---
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _syncCalendar(); // Fetch data for the new day
            },
            onFormatChanged: (format) {
               if (_calendarFormat != format) setState(() => _calendarFormat = format);
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(color: AppTheme.goldAccent, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: AppTheme.goldAccent.withOpacity(0.5), shape: BoxShape.circle),
              defaultTextStyle: TextStyle(color: textColor),
              weekendTextStyle: TextStyle(color: textColor.withOpacity(0.6)),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
              rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
            ),
          ),
          
          const Divider(),

          // --- SCHEDULE LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _schedule.length,
              itemBuilder: (context, index) {
                final item = _schedule[index];

                if (item['type'] == 'gap') {
                  return SmartGapCard(item: item);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C234C) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['time'] ?? "00:00", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
                          Text(item['endTime'] ?? "00:00", style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.5))),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Container(height: 40, width: 2, color: AppTheme.goldAccent.withOpacity(0.2)),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'] ?? "Untitled", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                            Text(item['location'] ?? "Unknown", style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}