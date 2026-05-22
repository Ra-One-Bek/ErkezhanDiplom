import 'package:flutter/material.dart';

import '../models/recognition_history.dart';
import '../services/firestore_service.dart';

class HistoryViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<RecognitionHistory> _items = [];
  bool _isLoading = false;

  List<RecognitionHistory> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    try {
      _isLoading = true;
      notifyListeners();

      _items = await _firestoreService.loadHistory();
    } catch (e) {
      debugPrint("Ошибка загрузки истории: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHistoryItem(String id) async {
    await _firestoreService.deleteRecognition(id);

    _items.removeWhere((item) => item.id == id);

    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _firestoreService.clearHistory();

    _items.clear();

    notifyListeners();
  }
}