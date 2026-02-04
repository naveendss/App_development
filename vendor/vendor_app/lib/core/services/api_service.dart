import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      // Save token and user data
      if (response.data['access_token'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['access_token']);
        await _storage.write(key: 'user_id', value: response.data['user_id']);
        await _storage.write(key: 'user_type', value: response.data['user_type']);
      }
      
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        ...userData,
        'user_type': 'vendor',
      });
      
      // Save token and user data
      if (response.data['access_token'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['access_token']);
        await _storage.write(key: 'user_id', value: response.data['user_id']);
        await _storage.write(key: 'user_type', value: response.data['user_type']);
      }
      
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // Gym Management endpoints
  Future<List<dynamic>> getMyGyms() async {
    try {
      final response = await _dio.get('/gyms/vendor/my-gyms');
      return response.data ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createGym(Map<String, dynamic> gymData) async {
    try {
      final response = await _dio.post('/gyms', data: {
        ...gymData,
        'status': 'active', // Set to active immediately for testing
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateGym(String gymId, Map<String, dynamic> gymData) async {
    try {
      final response = await _dio.put('/gyms/$gymId', data: gymData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Equipment Management endpoints
  Future<List<dynamic>> getGymEquipment(String gymId) async {
    try {
      final response = await _dio.get('/equipment/gym/$gymId');
      return response.data ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createEquipment(Map<String, dynamic> equipmentData) async {
    try {
      final response = await _dio.post('/equipment', data: equipmentData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateEquipment(String equipmentId, Map<String, dynamic> equipmentData) async {
    try {
      final response = await _dio.put('/equipment/$equipmentId', data: equipmentData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteEquipment(String equipmentId) async {
    try {
      await _dio.delete('/equipment/$equipmentId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Time Slot Management endpoints
  Future<Map<String, dynamic>> createTimeSlot(Map<String, dynamic> slotData) async {
    try {
      final response = await _dio.post('/bookings/slots', data: slotData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createBulkTimeSlots(Map<String, dynamic> bulkData) async {
    try {
      final response = await _dio.post('/bookings/slots/bulk', data: bulkData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getGymSlots(String gymId, {String? date}) async {
    try {
      final response = await _dio.get('/bookings/slots/gym/$gymId', queryParameters: {
        if (date != null) 'slot_date': date,
      });
      return response.data ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generate default slots for equipment (helper method)
  Future<void> generateDefaultSlots(String gymId, {String? equipmentId}) async {
    try {
      final now = DateTime.now();
      final startDate = now.toIso8601String().split('T')[0];
      final endDate = now.add(const Duration(days: 7)).toIso8601String().split('T')[0];
      
      // Generate hourly slots from 6 AM to 10 PM
      final List<Map<String, dynamic>> timeSlots = [];
      for (int hour = 6; hour < 22; hour++) {
        timeSlots.add({
          'start_time': '${hour.toString().padLeft(2, '0')}:00:00',
          'end_time': '${(hour + 1).toString().padLeft(2, '0')}:00:00',
          'capacity': 5,
          'base_price': 100.0,
          'surge_multiplier': 1.0,
        });
      }
      
      await createBulkTimeSlots({
        'gym_id': gymId,
        if (equipmentId != null) 'equipment_id': equipmentId,
        'start_date': startDate,
        'end_date': endDate,
        'time_slots': timeSlots,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Booking Management endpoints
  Future<List<dynamic>> getGymBookings(String gymId, {String? date, String? status}) async {
    try {
      final response = await _dio.get('/bookings/gym/$gymId', queryParameters: {
        if (date != null) 'booking_date': date,
        if (status != null) 'status_filter': status,
      });
      return response.data ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    try {
      final response = await _dio.get('/bookings/vendor/booking-details/$bookingId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Dashboard endpoints
  Future<Map<String, dynamic>> getDashboardStats(String gymId) async {
    try {
      final response = await _dio.get('/bookings/vendor/dashboard/$gymId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Membership Pass endpoints
  Future<List<dynamic>> getGymPasses(String gymId) async {
    try {
      final response = await _dio.get('/memberships/passes/gym/$gymId');
      return response.data ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createPass(Map<String, dynamic> passData) async {
    try {
      final response = await _dio.post('/memberships/passes', data: passData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updatePass(String passId, Map<String, dynamic> passData) async {
    try {
      final response = await _dio.put('/memberships/passes/$passId', data: passData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Attendance endpoints
  Future<Map<String, dynamic>> scanQRCode(String qrData) async {
    try {
      final response = await _dio.post('/attendance/scan', data: {
        'qr_data': qrData,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getGymAttendance(String gymId, {String? date}) async {
    try {
      final response = await _dio.get('/attendance/gym/$gymId', queryParameters: {
        if (date != null) 'date': date,
      });
      return response.data ?? [];
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
          final statusCode = error.response?.statusCode;
          final message = error.response?.data['detail'] ?? error.response?.data['message'];
          
          if (statusCode == 401) {
            return 'Invalid credentials. Please try again.';
          } else if (statusCode == 403) {
            return 'Access denied. You don\'t have permission.';
          } else if (statusCode == 404) {
            return 'Resource not found.';
          } else if (message != null) {
            return message;
          }
          return 'Server error occurred';
        case DioExceptionType.cancel:
          return 'Request cancelled';
        default:
          return 'Network error. Please check your connection.';
      }
    }
    return 'An unexpected error occurred: ${error.toString()}';
  }
}
