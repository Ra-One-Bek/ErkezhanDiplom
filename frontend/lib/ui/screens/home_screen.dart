import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  int _calculateLevel(int count) {
    if (count >= 50) return 5;
    if (count >= 30) return 4;
    if (count >= 15) return 3;
    if (count >= 5) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final historyVM = context.watch<HistoryViewModel>();

    final email = authVM.userEmail;
    final name = email.split('@').first;
    final items = historyVM.items;
    final total = items.length;
    final level = _calculateLevel(total);
    final lastItem = items.isNotEmpty ? items.first : null;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.menu_rounded,
                    color: AppTheme.textDark,
                    size: 28,
                  ),
                  const Spacer(),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.darkGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                "Привет, $name 👋",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Готовы распознать новое растение?",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 26),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "PlantCare AI",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Готово к распознаванию растений и болезней",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.local_florist,
                      color: Colors.white,
                      size: 72,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Сегодня",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.analytics_outlined,
                      title: "Всего",
                      value: "$total",
                      subtitle: "распознаваний",
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.emoji_events_outlined,
                      title: "Уровень",
                      value: "$level",
                      subtitle: "достижение",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _LastRecognitionCard(
                plantName: lastItem?.plantName ?? "Нет данных",
                diseaseName: lastItem?.diseaseName ??
                    "Сделайте первое распознавание",
                confidence: lastItem?.confidence ?? "-",
              ),

              const SizedBox(height: 20),

              _TipCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.softGreen,
            child: Icon(
              icon,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _LastRecognitionCard extends StatelessWidget {
  final String plantName;
  final String diseaseName;
  final String confidence;

  const _LastRecognitionCard({
    required this.plantName,
    required this.diseaseName,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.softGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppTheme.primaryGreen,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Последнее распознавание",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  plantName,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  diseaseName,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            confidence,
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkGreen,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Совет: фотографируйте листья при хорошем освещении, чтобы модель дала более точный результат.",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.86),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}