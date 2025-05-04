class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final bool isAdmin;
  final List<String> favoriteCarIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage = '',
    this.isAdmin = false,
    List<String>? favoriteCarIds,
  }) : favoriteCarIds = favoriteCarIds ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'isAdmin': isAdmin,
      'favoriteCarIds': favoriteCarIds,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profileImage: json['profileImage'] as String? ?? '',
      isAdmin: json['isAdmin'] as bool? ?? false,
      favoriteCarIds: List<String>.from(json['favoriteCarIds'] ?? []),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    bool? isAdmin,
    List<String>? favoriteCarIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      isAdmin: isAdmin ?? this.isAdmin,
      favoriteCarIds: favoriteCarIds ?? this.favoriteCarIds,
    );
  }
} 