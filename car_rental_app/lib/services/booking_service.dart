import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:car_rental_app/models/booking.dart';
import 'api_config.dart';

class BookingService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      return userData['token'];
    }
    return null;
  }

  Future<List<Booking>> getUserBookings() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookings}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Booking.fromJson(item)).toList();
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réservations: $e');
    }
  }

  Future<Booking> createBooking({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookings}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'carId': carId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        print('Booking creation successful. Response body: $responseBody');
        return Booking.fromJson(responseBody);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la réservation: $e');
    }
  }

  Future<Booking> cancelBooking(String bookingId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.put(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.bookings}/$bookingId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Booking.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la réservation: $e');
    }
  }

  Future<List<Booking>> getPendingBookings() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookings}/pending'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        print('Pending bookings response body: $body');
        return body.map((item) => Booking.fromJson(item)).toList();
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des réservations en attente: $e');
    }
  }

  Future<Booking> updateBookingStatus(String bookingId, String status) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.put(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.bookings}/$bookingId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return Booking.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception(
          'Erreur lors de la mise à jour du statut de la réservation: $e');
    }
  }
}
