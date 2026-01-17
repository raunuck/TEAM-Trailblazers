import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _hasNewEvent = false; // <--- Controls the Red Dot

  final List<Widget> _screens = [
    const HomeScreen(),
    const LeaderboardScreen(),
    const VaultScreen(),
    const CommunityScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _setupRealtimeSubscription();
  }

  void _setupRealtimeSubscription() {
    // Listen to the 'community_events' table for INSERTs (New events)
    Supabase.instance.client
        .from('community_events')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .listen((data) {
          if (!mounted) return;

          if (data.isNotEmpty) {
            // Logic: If we are NOT on the Community tab (Index 3), show the badge
            if (_currentIndex != 3) {
              setState(() {
                _hasNewEvent = true;
              });

              // OPTIONAL: Show a popup notification (SnackBar)
              final latestEvent = data.last;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.goldAccent,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16), // Floating look
                  content: Text(
                    "New Event: ${latestEvent['title']}!", 
                    style: const TextStyle(color: AppTheme.darkBlue, fontWeight: FontWeight.bold)
                  ),
                  action: SnackBarAction(
                    label: 'VIEW',
                    textColor: AppTheme.darkBlue,
                    onPressed: () {
                      setState(() {
                        _currentIndex = 3; // Switch to Community Tab
                        _hasNewEvent = false; // Clear Badge
                      });
                    },
                  ),
                ),
              );
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            // If clicking Community (index 3), clear the badge
            if (index == 3) {
              _hasNewEvent = false;
            }
          });
        },
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        indicatorColor: AppTheme.goldAccent.withOpacity(0.2), // Changed to Gold to match your theme
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppTheme.goldAccent),
            label: 'Schedule',
          ),
          const NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: AppTheme.goldAccent),
            label: 'Rank',
          ),
          const NavigationDestination(
            icon: Icon(Icons.lock_outline),
            selectedIcon: Icon(Icons.lock_open, color: AppTheme.goldAccent),
            label: 'Vault',
          ),
          
          // --- COMMUNITY TAB WITH BADGE LOGIC ---
          NavigationDestination(
            // We wrap the icon in a Stack to overlay the red dot
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.groups_outlined),
                if (_hasNewEvent)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
              ],
            ),
            selectedIcon: const Icon(Icons.groups, color: AppTheme.goldAccent),
            label: 'Community',
          )
          // --------------------------------------
        ],
      ),
    );
  }
}