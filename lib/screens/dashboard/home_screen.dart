import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme.dart';
import '../../services/calendar_service.dart';
import '../../core/theme_controller.dart';
import '../../screens/gamification/whiteboard_screen.dart'; // Whiteboard
import '../../services/excel_service.dart'; // Excel

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSyncing = false;
  final CalendarService _calendarService = CalendarService();
  final ExcelService _excelService = ExcelService();
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week; 

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

  Future<void> _importExcel() async {
    try {
      final platformFile = await _excelService.pickExcelFile();
      if (platformFile == null) return; 

      setState(() => _isSyncing = true);
      
      final newTasks = await _excelService.parseTimetable(platformFile);
      
      setState(() {
        _schedule.addAll(newTasks);
        _isSyncing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Success! Added ${newTasks.length} classes.")),
      );
    } catch (e) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error importing file: $e")),
      );
    }
  }

  void _openWhiteboard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WhiteboardScreen()),
    );

    if (result != null && result is String) {
      _parseAndAddTask(result);
    }
  }

  // --- ROBUST SMART PARSER (Handles spaces & messy handwriting) ---
  void _parseAndAddTask(String rawText) {
    // 1. Pre-clean the text to help the AI
    // Converts "12 / 01" to "12/01", "5 : 30" to "5:30"
    String processingText = rawText.toLowerCase().trim();
    
    String title = rawText; 
    DateTime now = DateTime.now();
    DateTime targetDate = now;
    TimeOfDay targetTime = TimeOfDay.now();
    
    bool dateFound = false;
    bool timeFound = false;

    // --- 2. DETECT DATE ---
    // Matches: 12/01, 12-01, 12 / 01, 12 - 01
    final numericDateRegex = RegExp(r'\b(\d{1,2})\s*[/-]\s*(\d{1,2})\b');
    final numMatch = numericDateRegex.firstMatch(processingText);

    // Matches: 12 jan, jan 12, 12th jan
    final months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    final writtenDateRegex = RegExp(r'\b(\d{1,2})?(?:st|nd|rd|th)?\s*(' + months.join('|') + r')\s*(\d{1,2})?(?:st|nd|rd|th)?\b');
    final writtenMatch = writtenDateRegex.firstMatch(processingText);

    if (numMatch != null) {
      dateFound = true;
      int day = int.parse(numMatch.group(1)!);
      int month = int.parse(numMatch.group(2)!);
      targetDate = DateTime(now.year, month, day);
      if (targetDate.isBefore(now.subtract(const Duration(days: 1)))) {
        targetDate = DateTime(now.year + 1, month, day);
      }
      // Remove date from title
      title = title.replaceAll(RegExp(numMatch.group(0)!, caseSensitive: false), "");
    } 
    else if (writtenMatch != null) {
      dateFound = true;
      String monthStr = writtenMatch.group(2)!;
      int monthIndex = months.indexOf(monthStr) + 1;
      String? dayStr = writtenMatch.group(1) ?? writtenMatch.group(3);
      
      if (dayStr != null) {
        int day = int.parse(dayStr);
        targetDate = DateTime(now.year, monthIndex, day);
        if (targetDate.isBefore(now.subtract(const Duration(days: 1)))) {
          targetDate = DateTime(now.year + 1, monthIndex, day);
        }
        // Remove date from title
        String matchString = processingText.substring(writtenMatch.start, writtenMatch.end);
        title = title.replaceAll(RegExp(matchString, caseSensitive: false), "");
      }
    } 
    else if (processingText.contains("tomorrow")) {
      dateFound = true;
      targetDate = now.add(const Duration(days: 1));
      title = title.replaceAll(RegExp(r'tomorrow', caseSensitive: false), "");
    }

    // --- 3. DETECT TIME ---
    // Matches: 5pm, 5 pm, 5:30pm, 5.30 pm, 14:00
    // Group 1: Hour, Group 2: Minute (optional), Group 3: am/pm
    final timeRegex = RegExp(r'\b(\d{1,2})\s*(?:[:.]\s*(\d{2}))?\s*(am|pm)?\b');
    final matches = timeRegex.allMatches(processingText);
    
    // We loop through matches to avoid picking up the date as a time (like 12 in 12/01)
    for (final match in matches) {
        // If this number was already used for the date, skip it (simple check)
        if (dateFound && numMatch != null && match.group(0)!.contains(numMatch.group(0)!)) continue;

        // Check if it looks like a time (has am/pm OR has a colon/dot)
        bool hasMeridiem = match.group(3) != null;
        bool hasColon = match.group(0)!.contains(":") || match.group(0)!.contains(".");
        
        if (hasMeridiem || hasColon) {
            timeFound = true;
            int hour = int.parse(match.group(1)!);
            int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
            String? period = match.group(3);

            if (period == 'pm' && hour != 12) hour += 12;
            if (period == 'am' && hour == 12) hour = 0;

            targetTime = TimeOfDay(hour: hour, minute: minute);
            
            // Remove time from title
            String matchString = processingText.substring(match.start, match.end);
            title = title.replaceAll(RegExp(matchString, caseSensitive: false), "");
            break; // Stop after finding the first valid time
        }
    }

    // --- 4. CLEANUP TITLE ---
    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (title.isEmpty || title == "/") title = "Whiteboard Task";

    // --- 5. CREATE TASK ---
    final String startStr = "${targetTime.hour.toString().padLeft(2, '0')}:${targetTime.minute.toString().padLeft(2, '0')}";
    final int endHour = (targetTime.hour + 1) % 24;
    final String endStr = "${endHour.toString().padLeft(2, '0')}:${targetTime.minute.toString().padLeft(2, '0')}";
    
    setState(() {
      _schedule.add(ScheduleTask(
        id: DateTime.now().toString(),
        time: startStr,
        endTime: endStr,
        title: title, 
        location: "Created via Whiteboard",
        status: TaskStatus.scheduled,
        description: "Raw Input: '$rawText'",
      ));
      
      // Navigate calendar to that day so user sees it
      _selectedDay = targetDate;
      _focusedDay = targetDate;
    });

    // --- 6. DEBUG FEEDBACK (Tells you what happened) ---
    String feedback = "Created '$title'";
    if (dateFound) feedback += " on ${targetDate.day}/${targetDate.month}";
    else feedback += " (No Date Found)";
    
    if (timeFound) feedback += " at $startStr";
    else feedback += " (No Time Found)";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feedback), 
        duration: const Duration(seconds: 4),
        action: SnackBarAction(label: "DEBUG", onPressed: (){
           // Show raw text if user clicks Debug
          showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Raw Text Saw:"), content: Text(rawText)));
        }),
      ),
    );
  }

  // Helper to print nice date
  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}";
  }

  // --- 3. SYNC CALENDAR ---
  Future<void> _syncCalendar() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSyncing = false);
  }

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppTheme.goldAccent),
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
          
          // --- FULL MENU WITH 3 OPTIONS ---
          PopupMenuButton<String>(
            icon: _isSyncing 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.add_circle_outline, color: textColor),
            tooltip: "Add Schedule",
            onSelected: (value) {
              if (value == 'google') {
                _syncCalendar();
              } else if (value == 'excel') {
                _importExcel();
              } else if (value == 'whiteboard') {
                _openWhiteboard();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'google',
                child: Row(
                  children: [
                    Icon(Icons.sync, color: Colors.blue),
                    SizedBox(width: 12),
                    Text("Sync Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_view, color: Colors.green),
                    SizedBox(width: 12),
                    Text("Import Excel", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'whiteboard',
                child: Row(
                  children: [
                    Icon(Icons.draw, color: Colors.orange),
                    SizedBox(width: 12),
                    Text("Smart Whiteboard", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
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

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _schedule.length,
              itemBuilder: (context, index) {
                final task = _schedule[index];
                if (task.status == TaskStatus.free) {
                  return _buildFreeSlotCard(task, index);
                }
                return _buildTaskCard(task, index, isDark, textColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- RESTORED: Full Card Design ---
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
                if (task.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(task.description!, style: TextStyle(fontSize: 12, color: AppTheme.goldAccent, fontStyle: FontStyle.italic)),
                  )
              ],
            ),
          ),
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

  // --- RESTORED: Full Free Slot Design ---
  Widget _buildFreeSlotCard(ScheduleTask task, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A325E) : const Color(0xFFFCEFD0),
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

// --- AI SUGGESTION SHEET (Unchanged) ---
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
    await Future.delayed(const Duration(seconds: 2));
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