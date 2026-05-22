import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get userEmail =>
      _authService.currentUserEmail ?? "Пользователь";

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.login(
        email: email,
        password: password,
      );

      return true;
    } catch (error) {
      _errorMessage = "Ошибка входа. Проверьте email и пароль.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.register(
        email: email,
        password: password,
      );

      return true;
    } catch (error) {
      _errorMessage = "Ошибка регистрации. Проверьте данные.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
  }
}