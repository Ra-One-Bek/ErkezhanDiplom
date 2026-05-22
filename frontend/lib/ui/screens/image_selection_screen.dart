import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/firestore_service.dart';
import '../../viewmodels/classification_viewmodel.dart';
import '../../viewmodels/image_selection_viewmodel.dart';
import '../theme/app_theme.dart';

class ImageSelectionScreen extends StatelessWidget {
  const ImageSelectionScreen({super.key});

  Future<void> _analyzeSelectedImage(BuildContext context) async {
    final imageVM = context.read<ImageSelectionViewModel>();
    final classificationVM = context.read<ClassificationViewModel>();
    final firestoreService = FirestoreService();
    final router = GoRouter.of(context);

    if (imageVM.selectedImage == null) {
      return;
    }

    try {
      final imagePath = imageVM.selectedImage!.path;

      router.go('/analyzing');

      await classificationVM.classifyImage(imagePath);

      final result = classificationVM.result;

      if (result != null) {
        await firestoreService.saveRecognition(
          plantName: result.plantName,
          diseaseName: result.diseaseName,
          confidence: result.confidence,
          imagePath: imagePath,
        );
      }

      router.go('/result');
    } catch (error) {
      debugPrint("Ошибка анализа изображения: $error");

      router.go('/image');

      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ошибка анализа: $error"),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageVM = context.watch<ImageSelectionViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text("Выбор изображения"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppTheme.softGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  size: 68,
                  color: AppTheme.primaryGreen,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Загрузите фото\nрастения",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "После выбора изображения приложение передаст его модели классификации",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: () async {
                  await imageVM.pickImageFromGallery();
                  await _analyzeSelectedImage(context);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text("Выбрать из галереи"),
              ),

              const SizedBox(height: 14),

              OutlinedButton.icon(
                onPressed: () async {
                  await imageVM.takePhoto();
                  await _analyzeSelectedImage(context);
                },
                icon: const Icon(Icons.photo_camera),
                label: const Text("Открыть камеру"),
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

              const SizedBox(height: 22),

              if (imageVM.selectedImage != null)
                Text(
                  "Выбрано: ${imageVM.selectedImage!.name}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}