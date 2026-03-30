import 'package:flutter/material.dart';
import 'package:valence/theme/valence_tokens.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      backgroundColor: tokens.colors.surfaceBackground,
      body: Center(
        child: Text(
          'Group',
          style: tokens.typography.h1,
        ),
      ),
    );
  }
}
