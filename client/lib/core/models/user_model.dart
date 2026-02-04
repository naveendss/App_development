class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String userType;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Customer profile fields
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? fitnessGoal;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    this.profileImageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.fitnessGoal,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      userType: json['user_type'] ?? 'customer',
      profileImageUrl: json['profile_image_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      age: json['age'],
      gender: json['gender'],
      heightCm: json['height_cm']?.toDouble(),
      weightKg: json['weight_kg']?.toDouble(),
      fitnessGoal: json['fitness_goal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'user_type': userType,
      'profile_image_url': profileImageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (fitnessGoal != null) 'fitness_goal': fitnessGoal,
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? userType,
    String? profileImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? fitnessGoal,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
    );
  }
  
  // Helper getters
  String get displayName => fullName;
  String get avatarUrl => profileImageUrl ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=$email';
}

