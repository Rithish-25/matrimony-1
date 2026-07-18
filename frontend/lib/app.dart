import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'models/person_model.dart';

class SoulmateApp extends StatelessWidget {
  const SoulmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soulmate Matrimony',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: AppState().isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
