class Car {
  final String id;
  final String brand;
  final String model;
  final int year;
  final double pricePerDay;
  final String image;
  final bool available;
  final String description;
  final String location;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.pricePerDay,
    required this.image,
    required this.available,
    required this.description,
    required this.location,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['_id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      pricePerDay: json['pricePerDay'].toDouble(),
      image: json['image'],
      available: json['available'],
      description: json['description'],
      location: json['location'],
      ownerId: json['owner']['_id'],
      ownerName: json['owner']['name'],
      ownerEmail: json['owner']['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'pricePerDay': pricePerDay,
      'image': image,
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
