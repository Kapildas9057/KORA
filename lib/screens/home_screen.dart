import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'tracking_screen.dart';
import 'dashboard_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // default to map/track tab

  final List<Widget> _screens = const [
    DashboardScreen(),
    TrackingScreen(),
    LeaderboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: const Border(top: BorderSide(color: AppTheme.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _NavItem(icon: Icons.bar_chart_rounded, label: 'STATS', index: 0, currentIndex: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.map_rounded, label: 'RUN', index: 1, currentIndex: currentIndex, onTap: onTap, isCenterAction: true),
            _NavItem(icon: Icons.emoji_events_rounded, label: 'RANKS', index: 2, currentIndex: currentIndex, onTap: onTap),
          ]),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, currentIndex;
  final ValueChanged<int> onTap;
  final bool isCenterAction;

  const _NavItem({
    required this.icon, required this.label,
    required this.index, required this.currentIndex,
    required this.onTap, this.isCenterAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    if (isCenterAction) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppTheme.accent : AppTheme.bgCard2,
            border: Border.all(
              color: isSelected ? AppTheme.accent : AppTheme.border,
              width: 2,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)]
                : [],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: isSelected ? AppTheme.accent : AppTheme.textSecondary, size: 22),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(
              color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
              fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ]),
      ),
    );
  }
}
