import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car_rental_app/models/car.dart';

class CarService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Récupérer toutes les voitures
  static Future<List<Map<String, dynamic>>> getAllCars() async {
    final response = await http.get(Uri.parse('$baseUrl/cars'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load cars');
    }
  }

  // Récupérer une voiture par son ID
  static Future<Map<String, dynamic>> getCarById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/cars/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load car');
    }
  }

  // Récupérer les voitures d'un propriétaire
  static Future<List<Map<String, dynamic>>> getCarsByOwner(
      String ownerId) async {
    final response = await http.get(Uri.parse('$baseUrl/cars/owner/$ownerId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load owner cars');
    }
  }

  // Ajouter une nouvelle voiture
  static Future<void> addCar({
    required String brand,
    required String model,
    required int year,
    required double pricePerDay,
    required String image,
    required String description,
    required String location,
    required String ownerId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cars'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'brand': brand,
        'model': model,
        'year': year,
        'pricePerDay': pricePerDay,
        'image': image,
        'description': description,
        'location': location,
        'ownerId': ownerId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add car');
    }
  }

  // Mettre à jour une voiture
  static Future<void> updateCar(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cars/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update car');
    }
  }

  // Supprimer une voiture
  static Future<void> deleteCar(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/cars/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete car');
    }
  }
}
