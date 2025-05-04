class Car {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String category;
  final List<String> images;
  final double price;
  final String description;
  final String ownerId;
  final bool isAvailable;
  final DateTime availableFrom;
  final DateTime availableTo;
  final List<String> features;
  final String location;
  final double rating;
  final List<Review> reviews;
  final bool isActive;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.category,
    required this.images,
    required this.price,
    required this.description,
    required this.ownerId,
    this.isAvailable = true,
    required this.availableFrom,
    required this.availableTo,
    required this.features,
    required this.location,
    this.rating = 0.0,
    List<Review>? reviews,
    this.isActive = true,
  }) : reviews = reviews ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'category': category,
      'images': images,
      'price': price,
      'description': description,
      'ownerId': ownerId,
      'isAvailable': isAvailable,
      'availableFrom': availableFrom.toIso8601String(),
      'availableTo': availableTo.toIso8601String(),
      'features': features,
      'location': location,
      'rating': rating,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'isActive': isActive,
    };
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      category: json['category'] as String,
      images: List<String>.from(json['images']),
      price: json['price'] as double,
      description: json['description'] as String,
      ownerId: json['ownerId'] as String,
      isAvailable: json['isAvailable'] as bool,
      availableFrom: DateTime.parse(json['availableFrom'] as String),
      availableTo: DateTime.parse(json['availableTo'] as String),
      features: List<String>.from(json['features']),
      location: json['location'] as String,
      rating: json['rating'] as double? ?? 0.0,
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((review) => Review.fromJson(review as Map<String, dynamic>))
          .toList() ?? [],
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Car copyWith({
    String? id,
    String? brand,
    String? model,
    int? year,
    String? category,
    List<String>? images,
    double? price,
    String? description,
    String? ownerId,
    bool? isAvailable,
    DateTime? availableFrom,
    DateTime? availableTo,
    List<String>? features,
    String? location,
    double? rating,
    List<Review>? reviews,
    bool? isActive,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      category: category ?? this.category,
      images: images ?? this.images,
      price: price ?? this.price,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      isAvailable: isAvailable ?? this.isAvailable,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      features: features ?? this.features,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      isActive: isActive ?? this.isActive,
    );
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