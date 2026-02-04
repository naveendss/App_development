class Gym {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String address;
  final String? city;
  final String? state;
  final String? zipCode;
  final double latitude;
  final double longitude;
  final String? contactPhone;
  final String? contactEmail;
  final double? rating;
  final int totalReviews;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Computed fields
  final double? distance;
  final List<String>? facilities;
  final String? status;
  final double? minPrice;  // Added for real pricing
  final String? primaryImage;  // Added for real images

  Gym({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    required this.address,
    this.city,
    this.state,
    this.zipCode,
    required this.latitude,
    required this.longitude,
    this.contactPhone,
    this.contactEmail,
    this.rating,
    this.totalReviews = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.distance,
    this.facilities,
    this.status,
    this.minPrice,
    this.primaryImage,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert UUID or string to string
    String parseId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) return value['value']?.toString() ?? value.toString();
      return value.toString();
    }
    
    return Gym(
      id: parseId(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      zipCode: json['zip_code']?.toString(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      contactPhone: json['contact_phone']?.toString() ?? json['phone']?.toString(),
      contactEmail: json['contact_email']?.toString() ?? json['email']?.toString(),
      rating: json['rating']?.toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      isActive: json['is_active'] ?? json['status'] == 'active',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString()) 
          : DateTime.now(),
      distance: json['distance_km']?.toDouble(),
      facilities: json['facilities'] != null 
          ? (json['facilities'] is List 
              ? List<String>.from(json['facilities'].map((f) => 
                  f is String ? f : (f['facility_type']?.toString() ?? 'Facility')))
              : null)
          : null,
      status: json['status']?.toString(),
      minPrice: json['min_price']?.toDouble(),
      primaryImage: json['primary_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (distance != null) 'distance': distance,
      if (facilities != null) 'facilities': facilities,
      if (status != null) 'status': status,
      if (minPrice != null) 'min_price': minPrice,
      if (primaryImage != null) 'primary_image': primaryImage,
    };
  }
  
  // Helper getters
  String get location => city != null && state != null ? '$city, $state' : address;
  String get imageUrl => primaryImage ?? logoUrl ?? 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800';
  String get displayRating => rating != null ? rating!.toStringAsFixed(1) : 'N/A';
  String get displayDistance => distance != null ? '${distance!.toStringAsFixed(1)} km' : '';
  String get displayPrice => minPrice != null ? '₹${minPrice!.toInt()}' : '₹150';
  bool get isOpen24x7 => status?.toLowerCase().contains('24') ?? false;
}
