import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gym_model.dart';

class GymService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  // For Android emulator use: 'http://10.0.2.2:8000/api/v1'
  // For iOS simulator use: 'http://localhost:8000/api/v1'
  // For physical device use: 'http://YOUR_IP:8000/api/v1'
  
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

  GymService() {
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

  // Get all gyms
  Future<List<Gym>> getGyms({int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get('/gyms', queryParameters: {
        'skip': skip,
        'limit': limit,
      });
      
      final List<dynamic> data = response.data;
      return data.map((json) => Gym.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Search gyms by location
  Future<List<Gym>> searchGyms({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      final response = await _dio.get('/gyms/search', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      });
      
      final List<dynamic> data = response.data;
      return data.map((json) => Gym.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get gym details
  Future<Gym> getGymDetails(String gymId) async {
    try {
      final response = await _dio.get('/gyms/$gymId');
      return Gym.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get gym equipment
  Future<List<Map<String, dynamic>>> getGymEquipment(String gymId) async {
    try {
      final response = await _dio.get('/equipment/gym/$gymId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get gym membership passes
  Future<List<Map<String, dynamic>>> getGymPasses(String gymId) async {
    try {
      final response = await _dio.get('/memberships/passes/gym/$gymId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get gym reviews
  Future<List<Map<String, dynamic>>> getGymReviews(String gymId) async {
    try {
      final response = await _dio.get('/reviews/gym/$gymId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Create review
  Future<Map<String, dynamic>> createReview({
    required String gymId,
    required int rating,
    String? reviewText,
  }) async {
    try {
      final response = await _dio.post('/reviews', data: {
        'gym_id': gymId,
        'rating': rating,
        if (reviewText != null) 'review_text': reviewText,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Save gym
  Future<void> saveGym(String gymId) async {
    try {
      await _dio.post('/saved-gyms', data: {'gym_id': gymId});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Unsave gym
  Future<void> unsaveGym(String gymId) async {
    try {
      await _dio.delete('/saved-gyms/$gymId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get saved gyms
  Future<List<Map<String, dynamic>>> getSavedGyms() async {
    try {
      final response = await _dio.get('/saved-gyms');
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
