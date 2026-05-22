import 'package:flutter/material.dart';

class RecognitionHistory {
  final String id;
  final String plantName;
  final String diseaseName;
  final String date;
  final String time;
  final String confidence;
  final IconData icon;
  final String? imagePath;

  const RecognitionHistory({
    required this.id,
    required this.plantName,
    required this.diseaseName,
    required this.date,
    required this.time,
    required this.confidence,
    required this.icon,
    this.imagePath,
  });
}