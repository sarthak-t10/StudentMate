import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiService {
  // Update the base URL based on your environment:
  // Local Development: 'http://localhost:5000/api/v1'
  // Physical Device: 'http://YOUR_MACHINE_IP:5000/api/v1'
  // Production: 'https://your-production-url/api/v1'
  static const String _baseUrl = 'http://localhost:5000/api/v1';
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle token refresh or logout
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      return null;
    }
  }

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  Future<bool> isTokenExpired() async {
    try {
      String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return true;
      return JwtDecoder.isExpired(token);
    } catch (e) {
      return true;
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> setUserData(String userData) async {
    await _secureStorage.write(key: 'user_data', value: userData);
  }

  Future<String?> getUserData() async {
    return await _secureStorage.read(key: 'user_data');
  }

  Future<void> clearUserData() async {
    await _secureStorage.delete(key: 'user_data');
  }

  Dio getDio() => _dio;
}
