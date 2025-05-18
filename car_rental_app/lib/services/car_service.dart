import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class CarService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Map<String, dynamic>>> getCars() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cars}'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load cars');
      }
    } catch (e) {
      throw Exception('Failed to load cars: $e');
    }
  }

  Future<Map<String, dynamic>> getCarById(String id) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cars}/$id'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load car');
      }
    } catch (e) {
      throw Exception('Failed to load car: $e');
    }
  }

  Future<Map<String, dynamic>> createCar({
    required String brand,
    required String model,
    required int year,
    required double pricePerDay,
    required String description,
    required String location,
    required String image,
    required String owner,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cars}'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'brand': brand,
          'model': model,
          'year': year,
          'pricePerDay': pricePerDay,
          'description': description,
          'location': location,
          'image': image,
          'owner': owner,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Failed to create car: $e');
    }
  }

  Future<Map<String, dynamic>> updateCar(
      String id, Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cars}/$id'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Failed to update car: $e');
    }
  }

  Future<void> deleteCar(String id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cars}/$id'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Failed to delete car: $e');
    }
  }
}
