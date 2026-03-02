import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('accounting_user');

    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        notifyListeners();
      } catch (e) {
        // Handle error, maybe clear corrupted data
        await prefs.remove('accounting_user');
      }
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('accounting_users') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      // Find user with matching credentials
      final userData = users.firstWhere(
        (user) => user['username'] == username && user['password'] == password,
        orElse: () => null,
      );

      if (userData != null) {
        _user = User.fromJson(userData);
        _isAuthenticated = true;

        // Save current user
        await prefs.setString('accounting_user', jsonEncode(_user!.toJson()));
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(UserWithPassword userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('accounting_users') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      // Check if username already exists
      final existingUser = users.firstWhere(
        (user) => user['username'] == userData.username,
        orElse: () => null,
      );

      if (existingUser != null) {
        return false; // Username already exists
      }

      // Add new user
      users.add(userData.toJson());
      await prefs.setString('accounting_users', jsonEncode(users));

      // Auto login after signup
      _user = User(
        firstName: userData.firstName,
        lastName: userData.lastName,
        companyName: userData.companyName,
        username: userData.username,
      );
      _isAuthenticated = true;

      await prefs.setString('accounting_user', jsonEncode(_user!.toJson()));
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accounting_user');

    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Method to update user information
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}
