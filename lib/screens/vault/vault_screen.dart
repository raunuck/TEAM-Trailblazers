import 'package:flutter/material.dart';
import '../../core/theme.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Knowledge Vault"), centerTitle: true, automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildVaultCategory(context, "My Interests", Icons.favorite, ["Computer Architecture", "Data Structures", "Public Speaking"]),
          const SizedBox(height: 20),
          _buildVaultCategory(context, "Saved Resources", Icons.bookmark, ["Lecture Notes: Pipelining", "Project Idea: AI Quiz"]),
        ],
      ),
    );
  }

  Widget _buildVaultCategory(BuildContext context, String title, IconData icon, List<String> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, color: AppTheme.goldAccent), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF1C234C) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.goldAccent.withOpacity(0.2))),
          child: Column(children: items.map((item) => ListTile(title: Text(item), trailing: const Icon(Icons.arrow_forward_ios, size: 14))).toList()),
        )
      ],
    );
  }
}