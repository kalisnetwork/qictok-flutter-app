import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  UserModel? _user;
  String? _token;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
    }
    _isLoading = false;
    notifyListeners();
    
    if (_token != null) {
      // Background refresh me
      unawaitedFetchMe();
    }
  }

  Future<void> unawaitedFetchMe() async {
    try {
      final resp = await _api.getMe();
      if (resp.data['status'] == true) {
        _user = UserModel.fromJson(resp.data['data']['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));
        notifyListeners();
      }
    } catch (_) {
      // If token invalid, maybe logout?
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final resp = await _api.login(email, password);
      if (resp.data['status'] == true) {
        final userData = resp.data['data']['user'];
        _token = resp.data['data']['token'];
        _user = UserModel.fromJson(userData);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));
        
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Login error: $e");
    }
    return false;
  }

  Future<bool> register(String username, String fullname, String email, String password) async {
    try {
      final resp = await _api.register(username, fullname, email, password);
      if (resp.data['status'] == true) {
        final userData = resp.data['data']['user'];
        _token = resp.data['data']['token'];
        _user = UserModel.fromJson(userData);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));
        
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Register error: $e");
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
