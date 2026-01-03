import 'package:flutter/material.dart';
import '../../core/theme.dart'; // Use relative import to avoid path errors
import '../dashboard/home_screen.dart';


class InterestScreen extends StatefulWidget {
  final bool isStudent; // We pass this from the Login Screen

  const InterestScreen({super.key, required this.isStudent});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  // Hardcoded list of interests for now (SRS Requirement 3.5)
  final List<String> _interests = [
    "Coding", "Design", "Public Speaking", 
    "Writing", "Marketing", "Finance", 
    "Photography", "Wellness", "AI Tools"
  ];

  // This set stores what the user has clicked
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    color: AppTheme.textDarkBlue,
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
                  crossAxisCount: 2, // 2 items per row
                  childAspectRatio: 2.5, // Shape of the button (width/height)
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
                                color: AppTheme.primaryBlue.withValues(alpha: 0.3), // Updated syntax
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

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected.isEmpty
                  ? null
                  : () {
                      // Navigate to the Dashboard, removing all previous screens (can't go back to login easily)
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false, 
                      );
                    },

                child: const Text(
                  "Continue to Dashboard",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}