import 'package:flutter/material.dart';
import '../../core/theme.dart'; // Adjusted path if needed, or use 'package:...'
import 'dashboard/home_screen.dart';
import 'vault/vault_screen.dart';
import 'community/community_screen.dart';
import 'leaderboard/leaderboard_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // The 4 Main Pages
  final List<Widget> _screens = [
    const HomeScreen(),        // 0: Schedule
    const CommunityScreen(),   // 1: Community
    const VaultScreen(),       // 2: Vault
    const LeaderboardScreen(), // 3: Leaderboard
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryBlue.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppTheme.primaryBlue),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: AppTheme.primaryBlue),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_outline),
            selectedIcon: Icon(Icons.lock_open, color: AppTheme.primaryBlue),
            label: 'Vault',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: AppTheme.primaryBlue),
            label: 'Rank',
          ),
        ],
      ),
    );
  }
}