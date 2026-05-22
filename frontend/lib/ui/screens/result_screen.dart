import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/classification_viewmodel.dart';
import '../../viewmodels/image_selection_viewmodel.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageVM = context.watch<ImageSelectionViewModel>();
    final resultVM = context.watch<ClassificationViewModel>();

    final selectedImage = imageVM.selectedImage;
    final result = resultVM.result;
    final isUnknown = result != null && result.confidence < 0.50;

    final plantName = isUnknown
        ? "Растение не распознано"
        : result?.plantName ?? "-";

    final diseaseName = isUnknown
        ? "Недостаточно уверенности модели"
        : result?.diseaseName ?? "-";

    final confidence = result == null
        ? "-"
        : "${(result.confidence * 100).toStringAsFixed(1)}%";

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Stack(
        children: [
          SizedBox(
            height: 360,
            width: double.infinity,
            child: selectedImage == null
                ? Container(
                    color: AppTheme.softGreen,
                    child: const Icon(
                      Icons.image_search,
                      size: 90,
                      color: AppTheme.primaryGreen,
                    ),
                  )
                : Image.file(
                    File(selectedImage.path),
                    fit: BoxFit.cover,
                  ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  _TopButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  const Spacer(),
                  _TopButton(
                    icon: Icons.home_rounded,
                    onTap: () => context.go('/home'),
                  ),
                ],
              ),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.66,
            minChildSize: 0.58,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
                decoration: const BoxDecoration(
                  color: AppTheme.cream,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(34),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.softGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: AppTheme.primaryGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Identification Result",
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _ResultTile(
                      icon: Icons.local_florist_outlined,
                      label: "Вид растения",
                      value: plantName,
                      isWarning: isUnknown,
                    ),

                    const SizedBox(height: 12),

                    _ResultTile(
                      icon: Icons.health_and_safety_outlined,
                      label: "Состояние",
                      value: diseaseName,
                      isWarning: isUnknown,
                    ),

                    const SizedBox(height: 12),

                    _ResultTile(
                      icon: Icons.analytics_outlined,
                      label: "Точность модели",
                      value: confidence,
                    ),

                    const SizedBox(height: 22),

                    if (result != null && !isUnknown)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push(
                            '/details',
                            extra: {
                              "plantName": result.plantName,
                              "diseaseName": result.diseaseName,
                              "confidence": confidence,
                            },
                          );
                        },
                        icon: const Icon(Icons.open_in_full),
                        label: const Text("Открыть полностью"),
                      ),

                    if (result != null && !isUnknown)
                      const SizedBox(height: 14),

                    OutlinedButton.icon(
                      onPressed: () => context.go('/image'),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Выбрать другое изображение"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        minimumSize: const Size(double.infinity, 54),
                        side: const BorderSide(
                          color: AppTheme.primaryGreen,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "Image loaded · Result available · Stored in history",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.35),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.86),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: AppTheme.darkGreen,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isWarning;

  const _ResultTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isWarning ? Colors.red.shade700 : AppTheme.primaryGreen;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
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
              style: TextStyle(
                color: isWarning ? Colors.red.shade700 : AppTheme.textDark,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}