import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'package:car_rental_app/models/car.dart';
import 'package:car_rental_app/models/booking.dart';

class CarService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      return userData['token'];
    }
    return null;
  }

  Future<List<Car>> getCars({Map<String, dynamic>? filters}) async {
    try {
      // Build the query string from filters
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cars}').replace(
          queryParameters:
              filters?.map((key, value) => MapEntry(key, value.toString())));

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Car> cars = body
            .where((item) => item['status'] != 'pending')
            .map((dynamic item) => Car.fromJson(item))
            .toList();
        return cars;
      } else {
        print('Failed to load cars: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching cars: $e');
      return [];
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
    required String category,
    required List<String> features,
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
          'category': category,
          'features': features,
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

  Future<List<Car>> getPendingCars({String? token}) async {
    try {
      final authToken = token ?? await _getToken();
      if (authToken == null) {
        print('Token not found or not provided.');
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cars}/pending'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Car> cars =
            body.map((dynamic item) => Car.fromJson(item)).toList();
        return cars;
      } else {
        print('Failed to load pending cars: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching pending cars: $e');
      return [];
    }
  }

  Future<void> approveCar(String id, {String? token}) async {
    try {
      final authToken = token ?? await _getToken();
      if (authToken == null) throw Exception('Non authentifié');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cars}/$id/approve'),
        headers: ApiConfig.getHeaders(authToken),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Failed to approve car: $e');
    }
  }

  Future<void> rejectCar(String id, {String? token}) async {
    try {
      final authToken = token ?? await _getToken();
      if (authToken == null) throw Exception('Non authentifié');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cars}/$id/reject'),
        headers: ApiConfig.getHeaders(authToken),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Failed to reject car: $e');
    }
  }

  Future<List<Car>> getRejectedCars({String? token}) async {
    try {
      final authToken = token ?? await _getToken();
      if (authToken == null) {
        print('Token not found or not provided.');
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cars}/rejected'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Car> cars =
            body.map((dynamic item) => Car.fromJson(item)).toList();
        return cars;
      } else {
        print('Failed to load rejected cars: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching rejected cars: $e');
      return [];
    }
  }

  Future<bool> checkCarAvailability(
      String carId, DateTime startDate, DateTime endDate) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.cars}/$carId/check-availability'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['available'] ?? false;
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Erreur lors de la vérification de la disponibilité: $e');
    }
  }

  Future<List<Booking>> getUserBookings() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('Token not found. User not authenticated.');
        return [];
      }

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.bookings}'), // Assuming ApiConfig.bookings is '/api/bookings'
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Booking> bookings =
            body.map((dynamic item) => Booking.fromJson(item)).toList();
        return bookings;
      } else {
        print('Failed to load user bookings: ${response.statusCode}');
        // Consider throwing an exception or returning a specific error indicator
        return [];
      }
    } catch (e) {
      print('Error fetching user bookings: $e');
      // Consider throwing an exception or returning a specific error indicator
      return [];
    }
  }

  Future<Map<String, dynamic>> submitCarRating(
      String carId, int rating, String comment) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.cars}/$carId/ratings'), // Use the new backend route
        headers: ApiConfig.getHeaders(token), // Use existing headers utility
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 201) {
        // Backend should return the updated car or rating info
        return jsonDecode(response.body); // Return the response body
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Erreur lors de la soumission de la note : $e');
    }
  }
}
