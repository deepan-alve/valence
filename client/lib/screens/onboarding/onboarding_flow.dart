// client/lib/screens/onboarding/onboarding_flow.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/screens/onboarding/welcome_screen.dart';
import 'package:valence/screens/onboarding/pitch_carousel.dart';
import 'package:valence/screens/onboarding/theme_picker_screen.dart';

// Placeholder screens for pages 4-7 (built in Tasks 9+)
class _AuthPlaceholder extends StatelessWidget {
  const _AuthPlaceholder();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Auth Screen — Task 9')),
      );
}

class _HabitSetupPlaceholder extends StatelessWidget {
  const _HabitSetupPlaceholder();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Habit Setup — Task 10')),
      );
}

class _GroupSetupPlaceholder extends StatelessWidget {
  const _GroupSetupPlaceholder();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Group Setup — Task 10')),
      );
}

class _NotificationPlaceholder extends StatelessWidget {
  const _NotificationPlaceholder();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Notification Permission — Task 11')),
      );
}

/// Wraps the 7-screen onboarding flow in a PageView.
/// Navigation is driven by OnboardingProvider — swipe is disabled.
class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  static const List<Widget> _pages = [
    WelcomeScreen(),       // 0 — Welcome
    PitchCarousel(),       // 1 — Pitch / value prop carousel
    ThemePickerScreen(),   // 2 — Theme selection
    _AuthPlaceholder(),    // 3 — Sign up / Login
    _HabitSetupPlaceholder(), // 4 — Habit template picker
    _GroupSetupPlaceholder(),  // 5 — Create / Join / Solo
    _NotificationPlaceholder(), // 6 — Notification permission
  ];

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();

    // Keep a single controller but jump to the correct page reactively.
    return _OnboardingPageViewHost(currentPage: onboarding.currentPage);
  }
}

class _OnboardingPageViewHost extends StatefulWidget {
  final int currentPage;
  const _OnboardingPageViewHost({required this.currentPage});

  @override
  State<_OnboardingPageViewHost> createState() =>
      _OnboardingPageViewHostState();
}

class _OnboardingPageViewHostState extends State<_OnboardingPageViewHost> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.currentPage);
  }

  @override
  void didUpdateWidget(_OnboardingPageViewHost old) {
    super.didUpdateWidget(old);
    if (old.currentPage != widget.currentPage) {
      _controller.animateToPage(
        widget.currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      // Swipe disabled — navigation via buttons only
      physics: const NeverScrollableScrollPhysics(),
      itemCount: OnboardingFlow._pages.length,
      itemBuilder: (_, index) => OnboardingFlow._pages[index],
    );
  }
}
