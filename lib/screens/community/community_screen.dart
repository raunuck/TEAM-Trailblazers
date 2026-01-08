import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import 'create_event_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Stream to listen for real-time updates
  final _eventStream = Supabase.instance.client
      .from('community_events')
      .stream(primaryKey: ['id'])
      .order('event_time', ascending: true);

  // --- LOGIC: Join / Leave ---
  Future<void> _toggleJoin(String eventId, List<dynamic> currentParticipants) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final List<String> participants = List<String>.from(currentParticipants);
    final isJoined = participants.contains(userId);

    if (isJoined) {
      participants.remove(userId); // Leave
    } else {
      participants.add(userId); // Join
    }

    try {
      await Supabase.instance.client
          .from('community_events')
          .update({'participants': participants})
          .eq('id', eventId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Action failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0C1D) : const Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Campus Community", style: TextStyle(
          color: isDark ? Colors.white : AppTheme.darkBlue, 
          fontWeight: FontWeight.bold
        )),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateEventScreen()),
        ),
        label: const Text("Start Activity", style: TextStyle(color: AppTheme.darkBlue, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: AppTheme.darkBlue),
        backgroundColor: AppTheme.goldAccent,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _eventStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent));
          }

          final events = snapshot.data!;

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.diversity_3, size: 60, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 15),
                  Text("No activities yet.", style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600])),
                  const SizedBox(height: 5),
                  Text("Be the first to start one!", style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return _buildActivityCard(
                context: context, 
                event: events[index], 
                isDark: isDark
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityCard({
    required BuildContext context,
    required Map<String, dynamic> event,
    required bool isDark,
  }) {
    // Colors
    final cardBg = isDark ? const Color(0xFF1C234C) : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.darkBlue;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    // Data Parsing
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final participants = List<dynamic>.from(event['participants'] ?? []);
    final isJoined = participants.contains(userId);
    final date = DateTime.parse(event['event_time']);
    final tags = List<String>.from(event['tags'] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isJoined ? AppTheme.goldAccent : Colors.transparent, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tags
              Row(
                children: tags.take(3).map((t) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)
                  ),
                  child: Text(t, style: const TextStyle(fontSize: 10, color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
                )).toList(),
              ),
              // Time Left Logic (Simple)
              Text(
                DateFormat('h:mm a').format(date), 
                style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold, fontSize: 12)
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(event['title'] ?? 'Untitled', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: subTextColor),
              const SizedBox(width: 4),
              Text(event['location'] ?? 'Unknown', style: TextStyle(color: subTextColor)),
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
                  Text("${participants.length} joined", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
              ElevatedButton(
                onPressed: () => _toggleJoin(event['id'], participants),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isJoined ? Colors.transparent : AppTheme.goldAccent,
                  foregroundColor: isJoined ? textColor : AppTheme.darkBlue,
                  elevation: 0,
                  side: isJoined ? BorderSide(color: isDark ? Colors.grey : Colors.grey[300]!) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  minimumSize: const Size(0, 36),
                ),
                child: Text(isJoined ? "Leave" : "Join"),
              ),
            ],
          )
        ],
      ),
    );
  }
}