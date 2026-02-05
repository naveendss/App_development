import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
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

  PaymentService() {
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

  // Create payment
  Future<Map<String, dynamic>> createPayment({
    required double amount,
    required String paymentMethod,
    String? bookingId,
    String? membershipId,
    String? gymId,
    String? cardLastFour,
  }) async {
    try {
      final response = await _dio.post('/payments', data: {
        'amount': amount,
        'payment_method': paymentMethod,
        if (bookingId != null) 'booking_id': bookingId,
        if (membershipId != null) 'membership_id': membershipId,
        if (gymId != null) 'gym_id': gymId,
        if (cardLastFour != null) 'card_last_four': cardLastFour,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get my payments
  Future<List<Map<String, dynamic>>> getMyPayments({String? statusFilter}) async {
    try {
      final response = await _dio.get('/payments/my-payments', queryParameters: {
        if (statusFilter != null) 'status_filter': statusFilter,
      });
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get payment details
  Future<Map<String, dynamic>> getPaymentDetails(String paymentId) async {
    try {
      final response = await _dio.get('/payments/$paymentId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update payment status
  Future<Map<String, dynamic>> updatePaymentStatus({
    required String paymentId,
    required String status,
  }) async {
    try {
      final response = await _dio.put('/payments/$paymentId/status', data: {
        'payment_status': status,
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
