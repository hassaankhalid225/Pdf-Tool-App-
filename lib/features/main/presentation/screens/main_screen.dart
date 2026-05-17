import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_colors.dart';
import 'package:pdf_tool/features/home/presentation/screens/home_screen.dart';
import 'package:pdf_tool/features/history/presentation/screens/history_screen.dart';
import 'package:pdf_tool/features/settings/presentation/screens/settings_screen.dart';

import 'package:pdf_tool/core/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final theme = Theme.of(context);
    
    return Scaffold(
      body: IndexedStack(
        index: navProvider.currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navProvider.currentIndex,
        onTap: (index) {
          navProvider.setIndex(index);
        },
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        backgroundColor: theme.colorScheme.surface,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
