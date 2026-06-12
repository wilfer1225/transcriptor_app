import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TranscriptorApp());
}

class TranscriptorApp extends StatelessWidget {
  const TranscriptorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transcriptor de Audio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.card,
          error: AppColors.error,
        ),
        fontFamily: 'Segoe UI', // O la fuente que prefieras usar
      ),
      home: const HomeScreen(),
    );
  }
}
