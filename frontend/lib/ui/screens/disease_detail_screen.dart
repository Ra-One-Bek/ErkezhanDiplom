import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/gemini_service.dart';
import '../theme/app_theme.dart';

class DiseaseDetailScreen extends StatefulWidget {
  final String plantName;
  final String diseaseName;
  final String confidence;
  final String? imagePath;

  const DiseaseDetailScreen({
    super.key,
    required this.plantName,
    required this.diseaseName,
    required this.confidence,
    this.imagePath,
  });

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  final GeminiService _geminiService = GeminiService();

  bool _isLoading = true;
  String? _error;
  Map<String, String> _info = {};

  @override
  void initState() {
    super.initState();
    _loadGeminiInfo();
  }

  Future<void> _loadGeminiInfo() async {
    try {
      final text = await _geminiService.generatePlantDiseaseInfo(
        plantName: widget.plantName,
        diseaseName: widget.diseaseName,
      );

      if (!mounted) return;

      setState(() {
        _info = _parseGeminiText(text);
        _isLoading = false;
      });
    } catch (error) {
        debugPrint(
          "GEMINI ERROR: $error",
        );

        if (!mounted) return;

        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      }
  }

  Map<String, String> _parseGeminiText(String text) {
    final sections = <String, String>{};

    final titles = [
      "Описание растения",
      "Описание болезни",
      "Симптомы",
      "Причины",
      "Лечение",
      "Профилактика",
    ];

    for (int i = 0; i < titles.length; i++) {
      final title = titles[i];
      final start = text.indexOf("$title:");

      if (start == -1) {
        sections[title] = "Информация не найдена.";
        continue;
      }

      final contentStart = start + title.length + 1;
      int contentEnd = text.length;

      for (int j = i + 1; j < titles.length; j++) {
        final nextStart = text.indexOf("${titles[j]}:");
        if (nextStart != -1) {
          contentEnd = nextStart;
          break;
        }
      }

      sections[title] = text.substring(contentStart, contentEnd).trim();
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.imagePath != null &&
        widget.imagePath!.isNotEmpty &&
        File(widget.imagePath!).existsSync();

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const Spacer(),
                  const Text(
                    "Подробнее",
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: hasImage
                          ? Image.file(
                              File(widget.imagePath!),
                              width: double.infinity,
                              height: 190,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: double.infinity,
                              height: 190,
                              color: AppTheme.softGreen,
                              child: const Icon(
                                Icons.eco,
                                color: AppTheme.primaryGreen,
                                size: 70,
                              ),
                            ),
                    ),

                    const SizedBox(height: 18),

                    _ResultRow(
                      icon: Icons.local_florist_outlined,
                      title: "Растение",
                      value: widget.plantName,
                    ),

                    const SizedBox(height: 12),

                    _ResultRow(
                      icon: Icons.health_and_safety_outlined,
                      title: "Состояние",
                      value: widget.diseaseName,
                    ),

                    const SizedBox(height: 12),

                    _ResultRow(
                      icon: Icons.analytics_outlined,
                      title: "Точность",
                      value: widget.confidence,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(),
                )
              else if (_error != null)
                _InfoBlock(
                  title: "AI-рекомендация",
                  text: _error!,
                  icon: Icons.error_outline,
                )
              else ...[
                _InfoBlock(
                  title: "Описание растения",
                  text: _info["Описание растения"] ?? "-",
                  icon: Icons.spa_outlined,
                ),
                const SizedBox(height: 14),
                _InfoBlock(
                  title: "Описание болезни",
                  text: _info["Описание болезни"] ?? "-",
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: 14),
                _InfoBlock(
                  title: "Симптомы",
                  text: _info["Симптомы"] ?? "-",
                  icon: Icons.visibility_outlined,
                ),
                const SizedBox(height: 14),
                _InfoBlock(
                  title: "Причины",
                  text: _info["Причины"] ?? "-",
                  icon: Icons.science_outlined,
                ),
                const SizedBox(height: 14),
                _InfoBlock(
                  title: "Лечение",
                  text: _info["Лечение"] ?? "-",
                  icon: Icons.medical_services_outlined,
                ),
                const SizedBox(height: 14),
                _InfoBlock(
                  title: "Профилактика",
                  text: _info["Профилактика"] ?? "-",
                  icon: Icons.shield_outlined,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ResultRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;

  const _InfoBlock({
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.softGreen,
            child: Icon(icon, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}