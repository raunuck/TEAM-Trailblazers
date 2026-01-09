import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme.dart';
import '../../services/calendar_service.dart';
import '../../core/theme_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/activity_suggestion.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/excel_service.dart';
import '../../screens/gamification/whiteboard_screen.dart';

enum TaskStatus { scheduled, free, cancelled }

class ScheduleTask {
  String id;
  String time;
  String endTime;
  String title;
  String location;
  TaskStatus status;
  String? description;
  String? resourceUrl;
  String? resourceType;

  ScheduleTask({
    required this.id,
    required this.time,
    required this.endTime,
    required this.title,
    this.location = "",
    this.status = TaskStatus.scheduled,
    this.description,
    this.resourceUrl,
    this.resourceType,
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
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week; 

  final List<ScheduleTask> _schedule = [
    ScheduleTask(id: '1', time: "09:00", endTime: "10:30", title: "Computer Arch", location: "Lab 3"),
    ScheduleTask(id: '2', time: "10:30", endTime: "11:30", title: "Free Slot", status: TaskStatus.free),
    ScheduleTask(id: '3', time: "11:30", endTime: "12:30", title: "Database Sys", location: "Room 404"),
  ];
  final ExcelService _excelService = ExcelService();

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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Video': return Icons.play_circle_outline;
      case 'Practice': return Icons.code;
      case 'Article': return Icons.article_outlined;
      case 'Audio': return Icons.headphones;
      case 'Project': return Icons.build;
      default: return Icons.lightbulb_outline;
    }
  }


  void _mergeFreeSlots() {
    for (int i = _schedule.length - 2; i >= 0; i--) {
      final current = _schedule[i];
      final next = _schedule[i + 1];

      if (current.status == TaskStatus.free && next.status == TaskStatus.free) {
        setState(() {
          current.endTime = next.endTime;
          
          current.title = "Extended Free Slot";
          
          _schedule.removeAt(i + 1);
        });
      }
    }
  }

  int _calculateDuration(String startStr, String endStr) {
    try {
      final startParts = startStr.split(':').map(int.parse).toList();
      final endParts = endStr.split(':').map(int.parse).toList();

      final startMinutes = startParts[0] * 60 + startParts[1];
      final endMinutes = endParts[0] * 60 + endParts[1];

      return endMinutes - startMinutes;
    } catch (e) {
      return 30;
    }
  }

  void _cancelTask(int index) {
    setState(() {
      _schedule[index].status = TaskStatus.free;
      _schedule[index].title = "Free Slot";
      _schedule[index].location = "Available";
      _schedule[index].description = null;
    });

    _mergeFreeSlots(); 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Class cancelled. Checking for merged slots...")),
    );
  }

  void _openAISuggestions(int index) {
    final task = _schedule[index];
    final duration = _calculateDuration(task.time, task.endTime);

    showModalBottomSheet(
      context: context,
      builder: (context) => _AISuggestionSheet(
        timeSlot: "${task.time} - ${task.endTime}",
        durationMinutes: duration,
        onSelect: (newTitle, newDesc, newUrl, newType) {
          setState(() {
            _schedule[index].title = newTitle;
            _schedule[index].description = newDesc;
            _schedule[index].resourceUrl = newUrl;
            _schedule[index].resourceType = newType;
            _schedule[index].location = "Self Study";
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
        _mergeFreeSlots();
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

  void _openWhiteboard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WhiteboardScreen()),
    );

    if (result != null && result is String) {
      _parseAndAddTask(result);
    }
  }

  void _parseAndAddTask(String rawText) {
    String processingText = rawText.toLowerCase().trim();
    String title = rawText; 
    DateTime now = DateTime.now();
    DateTime targetDate = now;
    TimeOfDay targetTime = TimeOfDay.now();
    
    bool dateFound = false;
    bool timeFound = false;

    final numericDateRegex = RegExp(r'\b(\d{1,2})\s*[/-]\s*(\d{1,2})\b');
    final numMatch = numericDateRegex.firstMatch(processingText);

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
      title = title.replaceAll(RegExp(numMatch.group(0)!, caseSensitive: false), "");
    } else if (writtenMatch != null) {
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
        String matchString = processingText.substring(writtenMatch.start, writtenMatch.end);
        title = title.replaceAll(RegExp(matchString, caseSensitive: false), "");
      }
    } else if (processingText.contains("tomorrow")) {
      dateFound = true;
      targetDate = now.add(const Duration(days: 1));
      title = title.replaceAll(RegExp(r'tomorrow', caseSensitive: false), "");
    }

    final timeRegex = RegExp(r'\b(\d{1,2})\s*(?:[:.]\s*(\d{2}))?\s*(am|pm)?\b');
    final matches = timeRegex.allMatches(processingText);
    
    for (final match in matches) {
        if (dateFound && numMatch != null && match.group(0)!.contains(numMatch.group(0)!)) continue;
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
            String matchString = processingText.substring(match.start, match.end);
            title = title.replaceAll(RegExp(matchString, caseSensitive: false), "");
            break;
        }
    }

    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (title.isEmpty || title == "/") title = "Whiteboard Task";

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
      _selectedDay = targetDate;
      _focusedDay = targetDate;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Created '$title'${dateFound ? ' on ${targetDate.day}/${targetDate.month}' : ''} at $startStr"), 
        duration: const Duration(seconds: 4),
        action: SnackBarAction(label: "DEBUG", onPressed: (){
          showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Raw Text Saw:"), content: Text(rawText)));
        }),
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
        // ----------------------

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
          PopupMenuButton<String>(
            icon: _isSyncing 
                ? const SizedBox(
                    width: 20, height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : Icon(Icons.add_to_photos_outlined, color: textColor),
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
                    Icon(Icons.calendar_month, color: Colors.blue),
                    SizedBox(width: 12),
                    Text("Google Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_view, color: Colors.green),
                    SizedBox(width: 12),
                    Text("Import Timetable", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Text(
                      task.description!, 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)
                    ),
                  ),

                if (task.resourceUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: InkWell(
                      onTap: () => _launchURL(task.resourceUrl!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.goldAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconForType(task.resourceType ?? 'Link'),
                              size: 14, 
                              color: AppTheme.goldAccent
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Open ${task.resourceType ?? 'Resource'}",
                              style: const TextStyle(
                                color: AppTheme.goldAccent, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 12
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
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

class _AISuggestionSheet extends StatefulWidget {
  final String timeSlot;
  final int durationMinutes;
  final Function(String title, String desc, String url, String type) onSelect;

  const _AISuggestionSheet({
    required this.timeSlot, 
    required this.durationMinutes, 
    required this.onSelect
  });

  @override
  State<_AISuggestionSheet> createState() => _AISuggestionSheetState();
}

class _AISuggestionSheetState extends State<_AISuggestionSheet> {
  bool _isLoading = true;
  List<ActivitySuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _generateSmartSuggestions();
  }


  IconData _getIconForType(String type) {
    switch (type) {
      case 'Video': return Icons.play_circle_outline;
      case 'Practice': return Icons.code;
      case 'Article': return Icons.article_outlined;
      case 'Audio': return Icons.headphones;
      case 'Project': return Icons.build;
      default: return Icons.lightbulb_outline;
    }
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        text, 
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

void _showConfirmationDialog(ActivitySuggestion item) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(_getIconForType(item.resourceType), color: AppTheme.goldAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTag("${item.minDuration} min", Colors.blue),
                  const SizedBox(width: 8),
                  _buildTag(item.resourceType, Colors.orange),
                ],
              ),
              const SizedBox(height: 16),
              
              Text(
                item.description,
                style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
              ),
              
              const SizedBox(height: 20),
              
              InkWell(
                onTap: () => _launchURL(item.resourceUrl),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.open_in_new, size: 16, color: AppTheme.goldAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Open ${item.resourceType}", 
                          style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: isDark ? Colors.grey : Colors.grey[700])),
            ),
            ElevatedButton(
              onPressed: () {
                  Navigator.pop(context);
                  widget.onSelect(
                    item.title, 
                    item.description, 
                    item.resourceUrl, 
                    item.resourceType
                  ); 
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldAccent,
                foregroundColor: AppTheme.darkBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Add to Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateSmartSuggestions() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    List<String> userInterests = [];

    if (user != null) {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('interests')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && data['interests'] != null) {
        userInterests = List<String>.from(data['interests']);
      }
    }

    print("🔎 User Interests Found: $userInterests");

    final validTasks = taskLibrary.where((task) {
      final fitsTime = task.minDuration <= widget.durationMinutes;
      
      final isInteresting = userInterests.contains(task.category);

      return fitsTime && isInteresting;
    }).toList();

    validTasks.shuffle();
    
    if (mounted) {
      setState(() {
        _suggestions = validTasks.take(3).toList();
        _isLoading = false;
      });
    }

  } catch (e) {
    debugPrint("❌ Error generating suggestions: $e");
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      height: 450,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Suggestions for ${widget.timeSlot}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    Text(
                      "${widget.durationMinutes} min available", 
                      style: const TextStyle(fontSize: 12, color: AppTheme.goldAccent, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context), 
                icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.grey)
              )
            ],
          ),
          const SizedBox(height: 20),
          
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: AppTheme.goldAccent)))
          else if (_suggestions.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  "No specific tasks fit this short time slot.\nTry a quick breather!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                ),
              ),
            )
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
            child: Icon(
              _getIconForType(item.resourceType), 
              color: AppTheme.goldAccent, 
              size: 20
            ),
          ),
          
          title: Text(
            item.title, 
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)
          ),
          
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  item.description, 
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, 
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)
                  ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildTag("${item.minDuration} min", Colors.blue),
                  const SizedBox(width: 6),
                  _buildTag(item.resourceType, Colors.orange),
                ],
              )
            ],
          ),
          
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new, color: AppTheme.goldAccent),
            tooltip: "Open Resource",
            onPressed: () => _launchURL(item.resourceUrl),
          ),
          
          onTap: () => _showConfirmationDialog(item),
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
