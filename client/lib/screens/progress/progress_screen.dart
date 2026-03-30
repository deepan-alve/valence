import 'package:flutter/material.dart';
import 'package:valence/theme/valence_tokens.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      backgroundColor: tokens.colors.surfaceBackground,
      body: Center(
        child: Text(
          'Progress',
          style: tokens.typography.h1,
        ),
      ),
    );
  }
}
