import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
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

  String? _token;

  AuthService() {
    _loadToken();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired, clear it
            clearToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  bool get isAuthenticated => _token != null;

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone': phoneNumber,  // Changed from 'phone_number' to 'phone'
        'user_type': 'customer',
      });
      
      final token = response.data['access_token'];
      await _saveToken(token);
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final token = response.data['access_token'];
      await _saveToken(token);
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Verify token
  Future<bool> verifyToken() async {
    if (_token == null) return false;
    
    try {
      await _dio.get('/auth/verify-token');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await clearToken();
  }

  // Get current user
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update user profile
  Future<User> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final response = await _dio.put('/users/me', data: {
        if (fullName != null) 'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      });
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Create customer profile
  Future<Map<String, dynamic>> createCustomerProfile({
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? fitnessGoal,
  }) async {
    try {
      final response = await _dio.post('/users/customer-profile', data: {
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (height != null) 'height_cm': height,
        if (weight != null) 'weight_kg': weight,
        if (fitnessGoal != null) 'fitness_goal': fitnessGoal,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update customer profile
  Future<Map<String, dynamic>> updateCustomerProfile({
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? fitnessGoal,
  }) async {
    try {
      final response = await _dio.put('/users/customer-profile', data: {
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (height != null) 'height_cm': height,
        if (weight != null) 'weight_kg': weight,
        if (fitnessGoal != null) 'fitness_goal': fitnessGoal,
      });
      return response.data;
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
