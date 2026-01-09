import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import 'create_idea_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final _ideaStream = Supabase.instance.client
      .from('ideas')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Vault", style: TextStyle(
          color: isDark ? const Color.fromARGB(255, 255, 255, 255) : const Color(0xFF0A0C1D),
          fontWeight: FontWeight.bold, 
          letterSpacing: 1.2
          )),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? const Color(0xFF0A0C1D) : const Color.fromARGB(255, 255, 255, 255),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateIdeaScreen()),
        ),
        backgroundColor: AppTheme.goldAccent,
        icon: const Icon(Icons.edit, color: AppTheme.darkBlue),
        label: const Text(
          "Write Idea",
          style: TextStyle(color: AppTheme.darkBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ideaStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent));
          }

          final ideas = snapshot.data!;

          if (ideas.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppTheme.goldAccent),
                  const SizedBox(width: 10),
                  Text(
                    "My Ideas & Goals",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.darkBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ...ideas.map((idea) => _buildIdeaCard(context, idea, isDark)),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIdeaCard(BuildContext context, Map<String, dynamic> idea, bool isDark) {
    Color statusColor;
    switch (idea['status']) {
      case 'Completed': statusColor = Colors.green; break;
      case 'In Progress': statusColor = Colors.orange; break;
      default: statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateIdeaScreen(idea: idea), 
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C234C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.goldAccent.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    idea['title'] ?? '',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.darkBlue),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(idea['status'] ?? '', style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              idea['description'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 15),
            Text("Your vault is empty.", style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600], fontSize: 16)),
          ],
        ),
      ),
    );
  }
}