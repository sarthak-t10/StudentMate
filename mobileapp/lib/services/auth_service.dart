import 'package:dio/dio.dart';
import 'dart:convert';
import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<User?> login(String email, String password) async {
    try {
      final response = await _apiService.getDio().post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['data']['accessToken'];
        final userData = response.data['data']['user'];
        
        await _apiService.setToken(token);
        // Store user data as JSON string
        await _apiService.setUserData(json.encode(userData));
        return User.fromJson(userData);
      }
      throw Exception(response.data['message'] ?? 'Login failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  Future<User?> register(String email, String password, String name, String role) async {
    try {
      final response = await _apiService.getDio().post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final token = response.data['data']['accessToken'];
        final userData = response.data['data']['user'];
        
        await _apiService.setToken(token);
        // Store user data as JSON string
        await _apiService.setUserData(json.encode(userData));
        return User.fromJson(userData);
      }
      throw Exception(response.data['message'] ?? 'Registration failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  Future<User?> restoreUserSession() async {
    try {
      // Check if token exists and is not expired
      String? token = await _apiService.getToken();
      if (token == null) return null;

      bool isExpired = await _apiService.isTokenExpired();
      if (isExpired) {
        await logout();
        return null;
      }

      // Try to restore user data from storage
      String? userDataJson = await _apiService.getUserData();
      if (userDataJson != null) {
        final userData = json.decode(userDataJson);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      await _apiService.clearToken();
      await _apiService.clearUserData();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      String? token = await _apiService.getToken();
      if (token == null) return false;
      return !(await _apiService.isTokenExpired());
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendOtpResetPassword(String email) async {
    try {
      final response = await _apiService.getDio().post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await _apiService.getDio().post(
        '/auth/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }
}
