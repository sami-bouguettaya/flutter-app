import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  final SharedPreferences _prefs;
  Map<String, dynamic>? _user;

  AuthService(this._prefs);

  Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String password,
    required String telephone,
    required String adresse,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'password': password,
          'telephone': telephone,
          'adresse': adresse,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Échec de l\'enregistrement : $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final token = userData['token'];
        print('AuthService: login - Received token: $token');

        // Save user data and token
        final prefs = await SharedPreferences.getInstance();
        final userJson = jsonEncode({
          'id': userData['_id'],
          'name': userData['name'],
          'email': userData['email'],
          'token': token,
        });
        print('AuthService: login - Saving userJson: $userJson');
        await prefs.setString('user', userJson);
        print('AuthService: login - User data saved to SharedPreferences');

        _user = userData;

        return userData;
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Échec de la connexion : $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final userJson = _prefs.getString('user');
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    throw Exception('Utilisateur non connecté');
  }

  Future<void> addFavorite(String carId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Non authentifié');

      final uri = Uri.parse('${ApiConfig.baseUrl}/users/favorites/$carId');
      final headers = ApiConfig.getHeaders(token);

      print('AuthService: Sending POST request to: $uri');
      print('AuthService: Request Headers: $headers');

      final response = await http.post(
        uri,
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  Future<void> removeFavorite(String carId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/users/favorites/$carId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Erreur lors du retrait des favoris: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/favorites'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        // Assuming backend returns a list of car objects with _id
        return body.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des favoris: $e');
    }
  }

  Future<void> logout() async {
    await _prefs.remove('user');
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    print('AuthService: _getToken - userJson: $userJson');
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      print('AuthService: _getToken - userData token: ${userData['token']}');
      return userData['token'];
    }
    print('AuthService: _getToken - returning null (userJson was null)');
    return null;
  }
}
