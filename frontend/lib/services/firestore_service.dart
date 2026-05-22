import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/recognition_history.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? _historyCollection() {
    final user = _auth.currentUser;

    if (user == null) return null;

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("history");
  }

  Future<void> saveRecognition({
    required String plantName,
    required String diseaseName,
    required double confidence,
    String? imagePath,
  }) async {
    final history = _historyCollection();

    if (history == null) return;

    await history.add({
      "plantName": plantName,
      "diseaseName": diseaseName,
      "confidence": confidence,
      "imagePath": imagePath,
      "createdAt": Timestamp.now(),
    });
  }

  Future<List<RecognitionHistory>> loadHistory() async {
    final history = _historyCollection();

    if (history == null) return [];

    final snapshot = await history
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      final plantName = data["plantName"] ?? "-";
      final diseaseName = data["diseaseName"] ?? "-";
      final confidence = data["confidence"] ?? 0.0;
      final imagePath = data["imagePath"] as String?;

      final timestamp = data["createdAt"] as Timestamp?;
      final dateTime = timestamp?.toDate() ?? DateTime.now();

      final formattedDate =
          "${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}";

      final formattedTime =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

      return RecognitionHistory(
        id: doc.id,
        icon: Icons.eco,
        plantName: plantName,
        diseaseName: diseaseName,
        imagePath: imagePath,
        date: formattedDate,
        time: formattedTime,
        confidence: "${(confidence * 100).toStringAsFixed(1)}%",
      );
    }).toList();
  }

  Future<void> deleteRecognition(String id) async {
    final history = _historyCollection();

    if (history == null) return;

    await history.doc(id).delete();
  }

  Future<void> clearHistory() async {
    final history = _historyCollection();

    if (history == null) return;

    final snapshot = await history.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}