class Booking {
  final String id;
  final String userId;
  final String gymId;
  final String? equipmentId;
  final String slotId;
  final String? membershipId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final String? equipmentStation;
  final double totalPrice;
  final String status;
  final String? qrCodeUrl;
  final DateTime? checkedInAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields for display
  final String? gymName;
  final String? gymImage;
  final String? equipmentType;

  Booking({
    required this.id,
    required this.userId,
    required this.gymId,
    this.equipmentId,
    required this.slotId,
    this.membershipId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.equipmentStation,
    required this.totalPrice,
    required this.status,
    this.qrCodeUrl,
    this.checkedInAt,
    required this.createdAt,
    required this.updatedAt,
    this.gymName,
    this.gymImage,
    this.equipmentType,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      gymId: json['gym_id'] ?? '',
      equipmentId: json['equipment_id'],
      slotId: json['slot_id'] ?? '',
      membershipId: json['membership_id'],
      bookingDate: DateTime.parse(json['booking_date']),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      equipmentStation: json['equipment_station'],
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 'upcoming',
      qrCodeUrl: json['qr_code_url'],
      checkedInAt: json['checked_in_at'] != null 
          ? DateTime.parse(json['checked_in_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      gymName: json['gym_name'],
      gymImage: json['gym_image'],
      equipmentType: json['equipment_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'gym_id': gymId,
      'equipment_id': equipmentId,
      'slot_id': slotId,
      'membership_id': membershipId,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'equipment_station': equipmentStation,
      'total_price': totalPrice,
      'status': status,
      'qr_code_url': qrCodeUrl,
      'checked_in_at': checkedInAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (gymName != null) 'gym_name': gymName,
      if (gymImage != null) 'gym_image': gymImage,
      if (equipmentType != null) 'equipment_type': equipmentType,
    };
  }

  bool get isActive {
    return status == 'upcoming' || status == 'active';
  }

  bool get isPast {
    return status == 'completed' || status == 'cancelled';
  }
  
  bool get isUpcoming {
    return status == 'upcoming' && bookingDate.isAfter(DateTime.now());
  }
  
  bool get canCancel {
    return status == 'upcoming' && bookingDate.isAfter(DateTime.now());
  }
  
  bool get canCheckIn {
    return status == 'upcoming' && 
           bookingDate.year == DateTime.now().year &&
           bookingDate.month == DateTime.now().month &&
           bookingDate.day == DateTime.now().day;
  }
  
  String get timeSlot => '$startTime - $endTime';
  String get displayPrice => '₹${totalPrice.toStringAsFixed(0)}';
}
