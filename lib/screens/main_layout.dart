import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'dashboard/home_screen.dart';
import 'community/community_screen.dart';
import 'vault/vault_screen.dart';
import 'leaderboard/leaderboard_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // The list of screens for the Bottom Navigation Bar
  final List<Widget> _screens = [
    const HomeScreen(),
    const LeaderboardScreen(),
    const VaultScreen(),
    const CommunityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        indicatorColor: AppTheme.primaryBlue.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppTheme.primaryBlue),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: AppTheme.primaryBlue),
            label: 'Rank',
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_outline),
            selectedIcon: Icon(Icons.lock_open, color: AppTheme.primaryBlue),
            label: 'Vault',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: AppTheme.primaryBlue),
            label: 'Community',
          )
        ],
      ),
    );
  }
}