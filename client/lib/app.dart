import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/theme/theme_provider.dart';
import 'package:valence/theme/valence_tokens.dart';

class ValenceApp extends StatelessWidget {
  const ValenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Valence',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const _DesignSystemPreview(),
          );
        },
      ),
    );
  }
}

class _DesignSystemPreview extends StatelessWidget {
  const _DesignSystemPreview();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: tokens.colors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: tokens.colors.surfacePrimary,
        title: Text(
          'Valence Design System',
          style: tokens.typography.h3.copyWith(color: tokens.colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: tokens.colors.textPrimary,
            ),
            tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
            onPressed: () {
              themeProvider.setTheme(
                isDark ? 'daybreak' : 'nocturnal_sanctuary',
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Design System Ready — Phase 2 builds the real UI',
            style: tokens.typography.body.copyWith(
              color: tokens.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
