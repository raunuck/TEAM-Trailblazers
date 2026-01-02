import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leaderboard"), backgroundColor: Colors.white, elevation: 0),
      body: const Center(child: Text("Productivity Rankings Coming Soon!")),
    );
  }
}