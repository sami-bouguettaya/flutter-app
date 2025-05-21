class Car {
  final String id;
  final String brand;
  final String model;
  final int year;
  final double pricePerDay;
  final String image;
  final String category;
  final double price;
  final double rating;
  final List<String> features;
  final bool available;
  final String description;
  final String location;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String? ownerPhone;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.pricePerDay,
    required this.image,
    required this.category,
    required this.price,
    required this.rating,
    required this.features,
    required this.available,
    required this.description,
    required this.location,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    this.ownerPhone,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    print('Parsing Car JSON: $json');
    // Safely access owner data, providing default values if owner is null
    final ownerData = json['owner'];
    final ownerId = ownerData != null ? ownerData['_id'] ?? '' : '';
    final ownerName =
        ownerData != null ? ownerData['nom'] ?? 'Unknown' : 'Unknown';
    final ownerEmail = ownerData != null ? ownerData['email'] ?? '' : '';
    final ownerPhone =
        ownerData != null ? ownerData['telephone'] ?? null : null;

    return Car(
      id: json['_id'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year']?.toInt() ?? 0,
      pricePerDay: json['pricePerDay']?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      price: json['pricePerDay']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble() ?? 0.0,
      features: List<String>.from(json['features'] ?? []),
      available: json['available'] ?? true,
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      ownerId: ownerId,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      ownerPhone: ownerPhone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'pricePerDay': pricePerDay,
      'image': image,
      'category': category,
      'price': price,
      'rating': rating,
      'features': features,
      'available': available,
      'description': description,
      'location': location,
      'owner': ownerId,
    };
  }
}

class Review {
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime date;

  Review({
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
