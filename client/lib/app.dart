import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/auth_provider.dart';
import 'package:valence/screens/splash/splash_screen.dart';
import 'package:valence/theme/theme_provider.dart';

class ValenceApp extends StatelessWidget {
  const ValenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Valence',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
