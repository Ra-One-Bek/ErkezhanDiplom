import 'package:flutter/material.dart';

import '../models/classification_result.dart';
import '../services/firestore_service.dart';
import '../services/tflite_service.dart';

class ClassificationViewModel extends ChangeNotifier {
  final TFLiteService _tfliteService = TFLiteService();
  final FirestoreService _firestoreService =
      FirestoreService();

  ClassificationResult? _result;

  bool _isLoading = false;

  ClassificationResult? get result => _result;

  bool get isLoading => _isLoading;

  Future<void> classifyImage(
    String imagePath,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prediction =
          await _tfliteService.classifyImage(
        imagePath,
      );

      _result = prediction;

      // сохраняем в Firebase
      await _firestoreService.saveRecognition(
        plantName: prediction.plantName,
        diseaseName: prediction.diseaseName,
        confidence: prediction.confidence,
      );

    } catch (e) {
      debugPrint(
        "Ошибка классификации: $e",
      );
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}