import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.goldAccent,
              onPrimary: AppTheme.darkBlue,
              surface: Color(0xFF1C234C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: _selectedTime);
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _selectedTime = time;
    });
  }

  Future<void> _postEvent() async {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title and Location are required")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Not logged in");

      final List<String> tags = _tagController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (tags.isEmpty) tags.add("General");

      final fullDateTime = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute
      );

      await Supabase.instance.client.from('community_events').insert({
        'creator_id': user.id,
        'title': _titleController.text.trim(),
        'location': _locationController.text.trim(),
        'event_time': fullDateTime.toIso8601String(),
        'tags': tags,
        'participants': [user.id],
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0C1D) : const Color(0xFFF9F9F9);
    final textColor = isDark ? Colors.white : AppTheme.darkBlue;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("HOST ACTIVITY", style: TextStyle(fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: _isSaving ? null : _postEvent,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.goldAccent,
                foregroundColor: AppTheme.darkBlue,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.darkBlue)) 
                : const Text("POST", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInput("EVENT TITLE", "E.g. Flutter Study Group", _titleController, textColor, isDark),
            const SizedBox(height: 20),
            _buildInput("LOCATION", "E.g. Library Room 304", _locationController, textColor, isDark),
            const SizedBox(height: 20),
            _buildInput("TAGS (Comma separated)", "Tech, Study, Social", _tagController, textColor, isDark),
            const SizedBox(height: 30),
            
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppTheme.goldAccent),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("WHEN", style: TextStyle(fontSize: 10, color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy  •  h:mm a').format(_selectedDate),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, String hint, TextEditingController controller, Color textColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
            filled: true,
            fillColor: isDark ? const Color(0xFF1C234C) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}