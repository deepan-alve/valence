import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/screens/home/home_screen.dart';
import 'package:valence/screens/group/group_screen.dart';
import 'package:valence/screens/progress/progress_screen.dart';
import 'package:valence/screens/shop/shop_screen.dart';
import 'package:valence/screens/profile/profile_screen.dart';
import 'package:valence/screens/home/habit_form_screen.dart';

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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          border: Border(
            top: BorderSide(color: colors.borderDefault, width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(
                  icon: PhosphorIcons.house(),
                  label: 'Home',
                  active: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                  colors: colors,
                ),
                _NavItem(
                  icon: PhosphorIcons.usersThree(),
                  label: 'Group',
                  active: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                  colors: colors,
                ),

                // Center + button
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const HabitFormScreen()),
                      ),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.accentPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.accentPrimary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.add_rounded,
                            color: colors.textInverse, size: 28),
                      ),
                    ),
                  ),
                ),

                _NavItem(
                  icon: PhosphorIcons.chartLineUp(),
                  label: 'Progress',
                  active: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                  colors: colors,
                ),
                _NavItem(
                  icon: PhosphorIcons.user(),
                  label: 'Profile',
                  active: _currentIndex == 4,
                  onTap: () => setState(() => _currentIndex = 4),
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final dynamic colors;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              icon,
              size: 24,
              color: active ? colors.accentPrimary : colors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? colors.accentPrimary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
