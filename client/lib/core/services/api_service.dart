import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  
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

  // Auth endpoints
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final response = await _dio.post('/auth/send-otp', data: {
        'phoneNumber': phoneNumber,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'phoneNumber': phoneNumber,
        'otp': otp,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Gym endpoints
  Future<List<dynamic>> getGyms({String? category, String? location}) async {
    try {
      final response = await _dio.get('/gyms', queryParameters: {
        if (category != null) 'category': category,
        if (location != null) 'location': location,
      });
      return response.data['gyms'] ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getGymDetails(String gymId) async {
    try {
      final response = await _dio.get('/gyms/$gymId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Booking endpoints
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await _dio.post('/bookings', data: bookingData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getUserBookings(String userId) async {
    try {
      final response = await _dio.get('/bookings/user/$userId');
      return response.data['bookings'] ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Pass endpoints
  Future<List<dynamic>> getPasses(String gymId) async {
    try {
      final response = await _dio.get('/passes/$gymId');
      return response.data['passes'] ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please try again.';
        case DioExceptionType.badResponse:
          return error.response?.data['message'] ?? 'Server error occurred';
        case DioExceptionType.cancel:
          return 'Request cancelled';
        default:
          return 'Network error. Please check your connection.';
      }
    }
    return 'An unexpected error occurred';
  }
}
