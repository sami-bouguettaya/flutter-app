import 'package:car_rental_app/models/car.dart';

class Booking {
  final String id;
  final String carId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final Car? car;

  Booking({
    required this.id,
    required this.carId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.car,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      carId: json['car']?['_id'] ?? '',
      userId: json['user']?['_id'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalPrice: json['totalPrice']?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      car: json['car'] != null ? Car.fromJson(json['car']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'car': carId,
      'user': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
