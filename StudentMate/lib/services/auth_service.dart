import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthService {
  static const String _userKey = 'current_user';
  late SharedPreferences _prefs;
  final UserRepository _userRepository = UserRepository();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Sign up - saves user to MongoDB
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    required String branch,
    required String section,
    required UserType userType,
    String? userPhotoUrl,
  }) async {
    try {
      // Check if email already exists in MongoDB
      final existingUser = await _userRepository.getUserByEmail(email);
      if (existingUser != null) {
        debugPrint('SignUp Error: Email already exists');
        return false;
      }

      final userId = const Uuid().v4();
      final user = User(
        id: userId,
        fullName: fullName,
        email: email,
        password: password,
        branch: branch,
        section: section,
        userPhotoUrl: userPhotoUrl,
        userType: userType,
        createdAt: DateTime.now(),
      );

      // Save to MongoDB
      await _userRepository.insertUser(user);
      await _saveCurrentUser(user);
      debugPrint('User registered successfully in MongoDB: $email');
      return true;
    } catch (e) {
      debugPrint('SignUp Error: $e');
      return false;
    }
  }

  /// Sign in - fetches user from MongoDB
  Future<(bool, User?)> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Find user in MongoDB by email
      final user = await _userRepository.getUserByEmail(email);

      if (user == null) {
        debugPrint('SignIn Error: No user found with email $email');
        return (false, null);
      }

      if (user.password != password) {
        debugPrint('SignIn Error: Invalid password');
        return (false, null);
      }

      await _saveCurrentUser(user);
      debugPrint('User signed in successfully from MongoDB: $email');
      return (true, user);
    } catch (e) {
      debugPrint('SignIn Error: $e');
      return (false, null);
    }
  }

  /// Save current user session to SharedPreferences
  Future<void> _saveCurrentUser(User user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _prefs.setString(_userKey, jsonStr);
  }

  /// Get current logged-in user from local session
  User? getCurrentUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Sign out - clears local session
  Future<void> signOut() async {
    await _prefs.remove(_userKey);
  }

  /// Check if a user is logged in
  bool isUserLoggedIn() {
    return _prefs.containsKey(_userKey);
  }

  /// Get user by ID from MongoDB
  Future<User?> getUserById(String userId) async {
    try {
      final users = await _userRepository.getAllUsers();
      return users.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw Exception('User not found'),
      );
    } catch (e) {
      debugPrint('getUserById Error: $e');
      return null;
    }
  }

  /// Re-fetches the current user from MongoDB and updates SharedPreferences.
  /// Call this on home screen load so admin-uploaded photos are reflected.
  Future<void> refreshFromDb() async {
    try {
      final cached = getCurrentUser();
      if (cached == null) return;
      final fresh = await _userRepository.getUserByEmail(cached.email);
      // Only update if we got the same user (guards against race conditions)
      if (fresh != null && fresh.id == cached.id) {
        await _saveCurrentUser(fresh);
      }
    } catch (_) {}
  }
}
