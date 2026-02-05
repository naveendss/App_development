import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_model.dart';

class BookingService {
  static const String baseUrl = 'https://app-development-il62.onrender.com/api/v1';
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  BookingService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // Get available time slots
  Future<List<Map<String, dynamic>>> getAvailableSlots({
    required String gymId,
    required String date,
    String? equipmentId,
  }) async {
    try {
      final response = await _dio.get('/bookings/slots/available', queryParameters: {
        'gym_id': gymId,
        'slot_date': date,
        if (equipmentId != null) 'equipment_id': equipmentId,
      });
      
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Create booking
  Future<Booking> createBooking({
    required String slotId,
    String? membershipId,
    String? equipmentStation,
  }) async {
    try {
      final response = await _dio.post('/bookings', data: {
        'slot_id': slotId,
        if (membershipId != null) 'membership_id': membershipId,
        if (equipmentStation != null) 'equipment_station': equipmentStation,
      });
      
      return Booking.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get my bookings
  Future<List<Booking>> getMyBookings({String? statusFilter}) async {
    try {
      final response = await _dio.get('/bookings/my-bookings', queryParameters: {
        if (statusFilter != null) 'status_filter': statusFilter,
      });
      
      final List<dynamic> data = response.data;
      return data.map((json) => Booking.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get booking details
  Future<Booking> getBookingDetails(String bookingId) async {
    try {
      final response = await _dio.get('/bookings/$bookingId');
      return Booking.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Cancel booking
  Future<Booking> cancelBooking(String bookingId) async {
    try {
      final response = await _dio.put('/bookings/$bookingId/cancel');
      return Booking.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Check in
  Future<Map<String, dynamic>> checkIn(String bookingId) async {
    try {
      final response = await _dio.post('/attendance/check-in', data: {
        'booking_id': bookingId,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Check out
  Future<Map<String, dynamic>> checkOut(String attendanceId) async {
    try {
      final response = await _dio.put('/attendance/$attendanceId/check-out');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get my attendance
  Future<List<Map<String, dynamic>>> getMyAttendance() async {
    try {
      final response = await _dio.get('/attendance/my-attendance');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      return 'Server error: ${error.response!.statusCode}';
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'An unexpected error occurred';
    }
  }
}
