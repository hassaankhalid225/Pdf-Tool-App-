import 'package:flutter/material.dart';
import 'package:pdf_tool/features/home/presentation/screens/home_screen.dart';
import 'package:pdf_tool/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:pdf_tool/features/history/presentation/screens/history_screen.dart';
import 'package:pdf_tool/features/settings/presentation/screens/settings_screen.dart';
import 'package:pdf_tool/core/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: navProvider.currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _FloatingBottomNav(
        currentIndex: navProvider.currentIndex,
        onTap: navProvider.setIndex,
      ),
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.10),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GNav(
              rippleColor: colorScheme.primary.withValues(alpha: 0.1),
              hoverColor: colorScheme.primary.withValues(alpha: 0.05),
              gap: 8,
              activeColor: colorScheme.primary,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              duration: const Duration(milliseconds: 300),
              tabBackgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              color: colorScheme.onSurface.withValues(alpha: 0.55),
              selectedIndex: currentIndex,
              onTabChange: onTap,
              tabs: const [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.star_rounded,
                  text: 'Favorites',
                ),
                GButton(
                  icon: Icons.folder_rounded,
                  text: 'Files',
                ),
                GButton(
                  icon: Icons.person_rounded,
                  text: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
