import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';

class CreateIdeaScreen extends StatefulWidget {
  final Map<String, dynamic>? idea; 

  const CreateIdeaScreen({super.key, this.idea});

  @override
  State<CreateIdeaScreen> createState() => _CreateIdeaScreenState();
}

class _CreateIdeaScreenState extends State<CreateIdeaScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  String _status = 'Not Started';
  bool _isSaving = false;
  final List<String> _statusOptions = ['Not Started', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    if (widget.idea != null) {
      _titleController.text = widget.idea!['title'] ?? '';
      _descController.text = widget.idea!['description'] ?? '';
      _status = widget.idea!['status'] ?? 'Not Started';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveIdea() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please give your idea a title")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User not logged in");
      }

      if (widget.idea == null) {
        await Supabase.instance.client.from('ideas').insert({
          'user_id': userId,
          'title': _titleController.text.trim(),
          'description': _descController.text.trim(),
          'status': _status,
        });
      } else {
        await Supabase.instance.client.from('ideas').update({
          'title': _titleController.text.trim(),
          'description': _descController.text.trim(),
          'status': _status,
        }).eq('id', widget.idea!['id']);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving: $e")));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0C1D) : const Color(0xFFF9F9F9);
    final surfaceColor = isDark ? const Color(0xFF131635) : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.darkBlue;
    final Color hintColor = (isDark ? Colors.grey[600] : Colors.grey[400])!;
    final String dateString = DateFormat('MMM dd, yyyy').format(DateTime.now());

    final screenTitle = widget.idea == null ? "NEW VAULT ENTRY" : "EDIT ENTRY";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0C1D) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          screenTitle, 
          style: const TextStyle(fontSize: 14,
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
          color: AppTheme.goldAccent)
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: _isSaving ? null : _saveIdea,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.goldAccent,
                foregroundColor: AppTheme.darkBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: _isSaving 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.darkBlue)) 
                  : const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
              color: surfaceColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ENTRY STATUS", style: TextStyle(color: hintColor, fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: _statusOptions.map((status) {
                      final isSelected = _status == status;
                      return GestureDetector(
                        onTap: () => setState(() => _status = status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.goldAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? AppTheme.goldAccent : (isDark ? Colors.grey[800]! : Colors.grey[300]!)),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isSelected ? AppTheme.darkBlue : (isDark ? Colors.grey : Colors.grey[600]),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 2, decoration: BoxDecoration(color: AppTheme.goldAccent.withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dateString, style: TextStyle(color: hintColor, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _titleController,
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor, height: 1.2),
                            decoration: InputDecoration.collapsed(
                              hintText: "What is the Big Idea?",
                              hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 25),
                          TextField(
                            controller: _descController,
                            style: TextStyle(fontSize: 16, height: 1.6, color: textColor.withOpacity(0.9)),
                            decoration: InputDecoration.collapsed(
                              hintText: "Describe your vision, next steps, and resources needed...",
                              hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
                            ),
                            maxLines: null,
                          ),
                          const SizedBox(height: 100),
                        ],
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