import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../screens/main_layout.dart'; 

class InterestScreen extends StatefulWidget {
  final bool isStudent;

  const InterestScreen({super.key, required this.isStudent});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  final List<String> _interests = [
    "Coding", "Design", "Public Speaking", 
    "Writing", "Marketing", "Finance", 
    "Photography", "Wellness", "AI Tools"
  ];

  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Explicit background color is safer
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Title based on Role
            Text(
              widget.isStudent 
                  ? "What do you want to learn?" 
                  : "What subjects do you teach?",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue, // Ensure this matches your theme variable name
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isStudent
                  ? "Select areas you want to improve in during your free slots."
                  : "We will customize your dashboard based on these domains.",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // The Grid of Interests
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final topic = _interests[index];
                  final isSelected = _selected.contains(topic);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(topic);
                        } else {
                          _selected.add(topic);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  // Note: 'withValues' is for Flutter 3.27+. 
                                  // If you get an error, use .withOpacity(0.3)
                                  color: AppTheme.primaryBlue.withOpacity(0.3), 
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        topic,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),

            // FIXED: Complete "Continue" Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Optional: Add validation here (e.g., must select at least 1)
                  if (_selected.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select at least one interest")),
                    );
                    return;
                  }

                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => const MainLayout()), 
                    (route) => false
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}