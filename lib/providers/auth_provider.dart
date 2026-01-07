import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> checkLoginStatus() async {
    final username = await _storageService.getCurrentSessionUser();
    if (username != null) {
      final users = await _storageService.getAllUsers();
      _currentUser = users[username];
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final user = await _storageService.loginUser(username, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String username, String password) async {
    _setLoading(true);
    try {
      final newUser = User(
        username: username,
        password: password,
        createdAt: DateTime.now(),
      );
      await _storageService.registerUser(newUser);
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _storageService.logoutUser();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
