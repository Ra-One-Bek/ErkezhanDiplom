import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelectionViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;

  XFile? get selectedImage => _selectedImage;

  Future<void> pickImageFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      _selectedImage = image;
      notifyListeners();
    }
  }

  Future<void> takePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      _selectedImage = image;
      notifyListeners();
    }
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }
}