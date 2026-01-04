import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme.dart';
import '../../services/calendar_service.dart';
import '../../core/theme_controller.dart';

enum TaskStatus { scheduled, free, cancelled }

class ScheduleTask {
  String id;
  String time;
  String endTime;
  String title;
  String location;
  TaskStatus status;
  String? description;

  ScheduleTask({
    required this.id,
    required this.time,
    required this.endTime,
    required this.title,
    this.location = "",
    this.status = TaskStatus.scheduled,
    this.description,
  });
}

// --- 2. THE MAIN SCREEN ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSyncing = false;
  final CalendarService _calendarService = CalendarService();
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week; 

  // Initial Mock Data converted to Model
  final List<ScheduleTask> _schedule = [
    ScheduleTask(id: '1', time: "09:00", endTime: "10:30", title: "Computer Arch", location: "Lab 3"),
    ScheduleTask(id: '2', time: "10:30", endTime: "11:30", title: "Free Slot", status: TaskStatus.free),
    ScheduleTask(id: '3', time: "11:30", endTime: "12:30", title: "Database Sys", location: "Room 404"),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // --- LOGIC: Cancel Class ---
  void _cancelTask(int index) {
    setState(() {
      _schedule[index].status = TaskStatus.free;
      _schedule[index].title = "Free Slot";
      _schedule[index].location = "Available";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Class cancelled. Time slot freed up!")),
    );
  }

  // --- LOGIC: AI Suggestions ---
  void _openAISuggestions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _AISuggestionSheet(
        timeSlot: "${_schedule[index].time} - ${_schedule[index].endTime}",
        onSelect: (newTitle, newDesc) {
          setState(() {
            _schedule[index].title = newTitle;
            _schedule[index].description = newDesc;
            _schedule[index].location = "Self Study / Library";
            _schedule[index].status = TaskStatus.scheduled; 
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _syncCalendar() async {
  setState(() => _isSyncing = true);

  try {
    final events = await _calendarService.fetchCalendarEvents(
      _selectedDay ?? DateTime.now(),
    );

    if (events != null && mounted) {
      setState(() {
        _schedule.clear();
        _schedule.addAll(events);
      });
    }
  } catch (e) {
    debugPrint("SYNC FAILED: $e");
  } finally {
    if (mounted) {
      setState(() => _isSyncing = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "PlanBEE", 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            letterSpacing: 1.2,
            color: isDark ? Colors.white : AppTheme.darkBlue 
          )
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: textColor),
            onPressed: () => themeController.toggleTheme(),
          ),
          IconButton(
            icon: Icon(_isSyncing ? Icons.hourglass_top : Icons.sync, color: textColor),
            onPressed: () {
              print("BUTTON CLICKED! Starting Sync..."); // <--- ADD THIS LINE
              _syncCalendar();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- CALENDAR WIDGET ---
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
              _syncCalendar();
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

          // --- TASK LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _schedule.length,
              itemBuilder: (context, index) {
                final task = _schedule[index];

                // 1. If it's a Free Slot (User cancelled or empty)
                if (task.status == TaskStatus.free) {
                  return _buildFreeSlotCard(task, index);
                }

                // 2. If it's a Normal Scheduled Task
                return _buildTaskCard(task, index, isDark, textColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Standard Task Card with 3-Dots ---
  Widget _buildTaskCard(ScheduleTask task, int index, bool isDark, Color textColor) {
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
              Text(task.time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
              Text(task.endTime, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.5))),
            ],
          ),
          const SizedBox(width: 20),
          Container(height: 40, width: 2, color: AppTheme.goldAccent.withOpacity(0.2)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                Text(task.location, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.6))),
                if (task.description != null) // Show description if added by AI
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(task.description!, style: TextStyle(fontSize: 12, color: AppTheme.goldAccent, fontStyle: FontStyle.italic)),
                  )
              ],
            ),
          ),
          // --- THE 3 DOTS MENU ---
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textColor.withOpacity(0.5)),
            onSelected: (value) {
              if (value == 'cancel') _cancelTask(index);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Cancel Class', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Free Slot Card with AI Button ---
  Widget _buildFreeSlotCard(ScheduleTask task, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A325E) : const Color(0xFFFCEFD0), // Using your "Gap" colors
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Free Slot (${task.time})", 
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    )
                  ),
                ],
              ),
              // AI Button
              ElevatedButton.icon(
                onPressed: () => _openAISuggestions(index),
                icon: const Icon(Icons.psychology, size: 16, color: Colors.white),
                label: const Text("Plan with AI"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "You have this time free. Let AI suggest a productive task or a break.",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13),
          )
        ],
      ),
    );
  }
}

// --- 3. AI SUGGESTION SHEET ---
class _AISuggestionSheet extends StatefulWidget {
  final String timeSlot;
  final Function(String title, String desc) onSelect;

  const _AISuggestionSheet({required this.timeSlot, required this.onSelect});

  @override
  State<_AISuggestionSheet> createState() => _AISuggestionSheetState();
}

class _AISuggestionSheetState extends State<_AISuggestionSheet> {
  bool _isLoading = true;
  List<Map<String, String>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    await Future.delayed(const Duration(seconds: 2)); // Mock AI Delay
    if (mounted) {
      setState(() {
        _isLoading = false;
        _suggestions = [
          {"title": "Deep Work Block", "desc": "Focus on your hardest project for 45 mins."},
          {"title": "Quick Revision", "desc": "Review notes from Computer Architecture."},
          {"title": "Mental Reset", "desc": "Take a walk or meditate to recharge."},
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      height: 400,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Suggestions for ${widget.timeSlot}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context), 
                icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.grey)
              )
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final item = _suggestions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: isDark ? Colors.grey[800] : Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.goldAccent.withOpacity(0.1),
                        child: const Icon(Icons.lightbulb_outline, color: AppTheme.goldAccent, size: 20),
                      ),
                      title: Text(item['title']!, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      subtitle: Text(item['desc']!, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
                      trailing: Icon(Icons.add_circle_outline, color: isDark ? Colors.white : Colors.black),
                      onTap: () => widget.onSelect(item['title']!, item['desc']!),
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }
}