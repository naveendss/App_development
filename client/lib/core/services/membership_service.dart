import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MembershipService {
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

  MembershipService() {
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

  // Get gym membership passes
  Future<List<Map<String, dynamic>>> getGymPasses(String gymId) async {
    try {
      final response = await _dio.get('/memberships/passes/gym/$gymId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get pass details
  Future<Map<String, dynamic>> getPassDetails(String passId) async {
    try {
      final response = await _dio.get('/memberships/passes/$passId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Purchase membership
  Future<Map<String, dynamic>> purchaseMembership(String passId) async {
    try {
      final response = await _dio.post('/memberships/user-memberships', data: {
        'pass_id': passId,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get my memberships
  Future<List<Map<String, dynamic>>> getMyMemberships({bool activeOnly = false}) async {
    try {
      final response = await _dio.get('/memberships/my-memberships', queryParameters: {
        'active_only': activeOnly,
      });
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get membership details
  Future<Map<String, dynamic>> getMembershipDetails(String membershipId) async {
    try {
      final response = await _dio.get('/memberships/user-memberships/$membershipId');
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
