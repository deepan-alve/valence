import 'package:flutter/material.dart';
import 'package:valence/theme/valence_tokens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      backgroundColor: tokens.colors.surfaceBackground,
      body: Center(
        child: Text(
          'Profile',
          style: tokens.typography.h1,
        ),
      ),
    );
  }
}
