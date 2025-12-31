import 'package:flutter/material.dart';
import '../../core/theme.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  // Mock Data to start with (SRS Requirement 3.7)
  final List<Map<String, dynamic>> _vaultItems = [
    {
      "title": "AI Quiz Generator",
      "description": "A python script that reads PDFs and generates questions.",
      "category": "Project",
      "priority": "High",
      "color": Colors.purple,
    },
    {
      "title": "Learn Flutter Animation",
      "description": "Master Hero widgets and implicit animations.",
      "category": "Goal",
      "priority": "Medium",
      "color": Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("The Vault", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      
      // Floating Action Button to Add New Ideas
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Idea", style: TextStyle(color: Colors.white)),
      ),

      body: _vaultItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _vaultItems.length,
              itemBuilder: (context, index) {
                return _buildVaultCard(_vaultItems[index]);
              },
            ),
    );
  }

  // --- WIDGETS ---

  Widget _buildVaultCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['category'].toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: item['color'],
                  ),
                ),
              ),
              // Priority Indicator
              if (item['priority'] == 'High')
                const Icon(Icons.flag, color: Colors.red, size: 20)
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item['title'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            item['description'],
            style: TextStyle(color: Colors.grey.shade600, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Your Vault is Empty",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 8),
          Text(
            "Capture your ideas before they fly away.",
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: Show Dialog to Add Item ---
  void _showAddDialog() {
    // Temporary variables for the form
    String title = "";
    String description = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Vault Entry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Title", hintText: "e.g., Build a robot"),
                onChanged: (val) => title = val,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: "Description", hintText: "Details..."),
                maxLines: 3,
                onChanged: (val) => description = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  setState(() {
                    _vaultItems.add({
                      "title": title,
                      "description": description,
                      "category": "Idea", // Default for now
                      "priority": "Low",
                      "color": Colors.blue,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Save to Vault"),
            ),
          ],
        );
      },
    );
  }
}