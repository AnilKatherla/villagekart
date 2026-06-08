import 'package:dio/dio.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/environmental_variables.dart';

class NetworkService {
  NetworkService(this._dio) {
    // Configure Dio
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from secure storage
          final accessToken = await SharedPrefs.getAccessToken();
          final warehouseId = await SharedPrefs.getWarehouseId();
          options.headers.addAll({
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'x-warehouse-id': warehouseId ?? '',
          });

          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors (e.g., token refresh)
          return handler.next(error);
        },
      ),
    );

    // Add logging in debug mode
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }
  final Dio _dio;

  static String get baseUrl => EnvironmentalVariables.baseUrl;

  // HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.delete(path, queryParameters: queryParameters);
  }
}
