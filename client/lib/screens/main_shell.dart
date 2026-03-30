import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/screens/home/home_screen.dart';
import 'package:valence/screens/group/group_screen.dart';
import 'package:valence/screens/progress/progress_screen.dart';
import 'package:valence/screens/shop/shop_screen.dart';
import 'package:valence/screens/profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    HomeScreen(),
    GroupScreen(),
    ProgressScreen(),
    ShopScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: colors.surfacePrimary,
        selectedItemColor: colors.accentPrimary,
        unselectedItemColor: colors.textSecondary,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.house()),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.usersThree()),
            label: 'Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.chartLineUp()),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.storefront()),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.user()),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
