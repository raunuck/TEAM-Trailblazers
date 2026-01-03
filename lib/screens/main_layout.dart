import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'dashboard/home_screen.dart';
import 'vault/vault_screen.dart';
import 'community/community_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text("Leaderboard Coming Soon")), // Placeholder
    const VaultScreen(),
    const CommunityScreen(), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: isDark ? AppTheme.darkBlue : Colors.white,
        indicatorColor: AppTheme.goldAccent.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_month, color: AppTheme.goldAccent), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events, color: AppTheme.goldAccent), label: 'Rank'),
          NavigationDestination(icon: Icon(Icons.lock_outline), selectedIcon: Icon(Icons.lock_open, color: AppTheme.goldAccent), label: 'Vault'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups, color: AppTheme.goldAccent), label: 'Community'),
        ],
      ),
    );
  }
}