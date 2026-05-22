import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/classification_result.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  Future<void> loadModel() async {
    try {
      _interpreter ??= await Interpreter.fromAsset(
        'assets/models/plant_disease_model.tflite',
      );

      if (_labels.isEmpty) {
        final labelsData = await rootBundle.loadString(
          'assets/labels/labels.txt',
        );

        _labels = labelsData
            .split('\n')
            .map((label) => label.trim())
            .where((label) => label.isNotEmpty)
            .toList();

        if (_labels.isEmpty) {
          throw Exception("Файл labels.txt пустой");
        }
      }
    } catch (error) {
      throw Exception("Ошибка загрузки модели: $error");
    }
  }

  Future<ClassificationResult> classifyImage(String imagePath) async {
    try {
      debugPrint("TFLITE: start");

      await loadModel();
      debugPrint("TFLITE: model loaded");

      final imageFile = File(imagePath);

      if (!await imageFile.exists()) {
        throw Exception("Файл изображения не найден: $imagePath");
      }

      debugPrint("TFLITE: image exists");

      final imageBytes = await imageFile.readAsBytes();
      debugPrint("TFLITE: image bytes read");

      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        throw Exception("Не удалось прочитать изображение");
      }

      debugPrint("TFLITE: image decoded");

      final resizedImage = img.copyResize(
        decodedImage,
        width: 224,
        height: 224,
      );

      debugPrint("TFLITE: image resized");

      final input = Float32List(1 * 224 * 224 * 3);
      int inputIndex = 0;

      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);

          input[inputIndex++] = pixel.r / 255.0;
          input[inputIndex++] = pixel.g / 255.0;
          input[inputIndex++] = pixel.b / 255.0;
        }
      }

      debugPrint("TFLITE: input prepared");

      final output = List.generate(
        1,
        (_) => List<double>.filled(_labels.length, 0.0),
      );

      debugPrint("TFLITE: before run");

      _interpreter!.run(
        input.reshape([1, 224, 224, 3]),
        output,
      );

      debugPrint("TFLITE: after run");

      final probabilities = output[0];

      if (probabilities.isEmpty) {
        throw Exception("Модель вернула пустой результат");
      }

      int maxIndex = 0;
      double maxConfidence = probabilities[0];

      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          maxIndex = i;
        }
      }

      if (maxIndex >= _labels.length) {
        throw Exception("Индекс результата не совпадает с labels.txt");
      }

      final rawLabel = _labels[maxIndex];
      final parsed = _parseLabel(rawLabel);

      debugPrint("TFLITE RESULT: $rawLabel $maxConfidence");

      return ClassificationResult(
        plantName: parsed.plantName,
        diseaseName: parsed.diseaseName,
        confidence: maxConfidence,
      );
    } catch (error) {
      debugPrint("TFLITE ERROR: $error");
      throw Exception("Ошибка классификации изображения: $error");
    }
  }

  _ParsedLabel _parseLabel(String label) {
    final parts = label.split('_');

    final plantName = parts.first.replaceAll('-', ' ');

    final diseaseName = parts.length > 1
        ? parts.sublist(1).join(' ').replaceAll('-', ' ')
        : "Healthy";

    return _ParsedLabel(
      plantName: plantName,
      diseaseName: diseaseName,
    );
  }
}

class _ParsedLabel {
  final String plantName;
  final String diseaseName;

  const _ParsedLabel({
    required this.plantName,
    required this.diseaseName,
  });
}