import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AnalyzingScreen extends StatelessWidget {
  const AnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  strokeWidth: 7,
                  color: AppTheme.primaryGreen,
                ),
              ),

              const SizedBox(height: 40),

              const Icon(
                Icons.eco,
                size: 90,
                color: AppTheme.primaryGreen,
              ),

              const SizedBox(height: 30),

              const Text(
                "Анализ изображения...",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Нейронная сеть определяет\nрастение и заболевание",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}