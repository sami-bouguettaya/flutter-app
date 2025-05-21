import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  AuthProvider(this._authService) {
    _loadUserLocal();
  }

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  AuthService get authService => _authService;

  Future<void> _loadUserLocal() async {
    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> register({
    required String nom,
    required String email,
    required String password,
    required String telephone,
    required String adresse,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.register(
        nom: nom,
        email: email,
        password: password,
        telephone: telephone,
        adresse: adresse,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData =
          await _authService.login(email: email, password: password);
      _user = userData;
      await _saveUserLocal(userData);
      notifyListeners();
    } catch (e) {
      // ... existing code ...
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await _authService.logout();
    notifyListeners();
  }

  Future<void> _saveUserLocal(Map<String, dynamic> userData) async {
    // This method might not be needed if AuthService handles local storage
    // Re-evaluate based on AuthService implementation
  }

  Future<void> addFavorite(String carId) async {
    if (_user == null) return;
    try {
      print(
          'AuthProvider: Calling AuthService.addFavorite for car ID: ${carId}');
      await _authService.addFavorite(carId);
      // Update local state after successful backend call
      final updatedUser = Map<String, dynamic>.from(_user!);
      final currentFavorites =
          List<String>.from(updatedUser['favorites'] ?? []);
      if (!currentFavorites.contains(carId)) {
        currentFavorites.add(carId);
        updatedUser['favorites'] = currentFavorites;
        _user = updatedUser;
        print('AuthProvider: Favorite added locally. Notifying listeners.');
        notifyListeners();
      }
    } catch (e) {
      print('AuthProvider Error adding favorite: $e');
      rethrow; // Rethrow to show error in UI
    }
  }

  Future<void> removeFavorite(String carId) async {
    if (_user == null) return;
    try {
      print(
          'AuthProvider: Calling AuthService.removeFavorite for car ID: ${carId}');
      await _authService.removeFavorite(carId);
      // Update local state after successful backend call
      final updatedUser = Map<String, dynamic>.from(_user!);
      final currentFavorites =
          List<String>.from(updatedUser['favorites'] ?? []);
      if (currentFavorites.contains(carId)) {
        currentFavorites.remove(carId);
        updatedUser['favorites'] = currentFavorites;
        _user = updatedUser;
        print('AuthProvider: Favorite removed locally. Notifying listeners.');
        notifyListeners();
      }
    } catch (e) {
      print('AuthProvider Error removing favorite: $e');
      rethrow; // Rethrow to show error in UI
    }
  }

  bool isFavorite(String carId) {
    if (_user == null) return false;
    final favorites = List<String>.from(_user!['favorites'] ?? []);
    return favorites.contains(carId);
  }
}
