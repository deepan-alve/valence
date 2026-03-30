import 'package:flutter/material.dart';
import 'package:valence/theme/valence_tokens.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      backgroundColor: tokens.colors.surfaceBackground,
      body: Center(
        child: Text(
          'Shop',
          style: tokens.typography.h1,
        ),
      ),
    );
  }
}
