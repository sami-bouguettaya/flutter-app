import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Inscription
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    final response = await ApiService.post('users/register', {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
    });
    await _saveUserData(response);
    return response;
  }

  // Connexion
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post('users/login', {
      'email': email,
      'password': password,
    });
    await _saveUserData(response);
    return response;
  }

  // Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Récupérer le profil utilisateur
  static Future<Map<String, dynamic>> getProfile() async {
    return await ApiService.get('users/profile');
  }

  // Sauvegarder les données utilisateur
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  // Récupérer les données utilisateur
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final userData = await getUserData();
    return userData != null;
  }
}
