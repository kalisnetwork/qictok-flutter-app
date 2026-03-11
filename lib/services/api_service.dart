import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://backend.digitalleadpro.com/api/v1';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        }
        return handler.next(response);
      },
      onError: (err, handler) {
        if (kDebugMode) {
          print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
        }
        return handler.next(err);
      },
    ));
  }

  // --- Diagnostic Endpoints ---
  Future<bool> checkConnection() async {
    try {
      final resp = await _dio.get('/posts', queryParameters: {'limit': 1});
      return resp.data['status'] == true;
    } catch (_) {
      return false;
    }
  }

  // --- Auth Endpoints ---
  Future<Response> login(String email, String password) => 
      _dio.post('/auth/login', data: {'email': email, 'password': password});

  Future<Response> register(String username, String fullname, String email, String password) =>
      _dio.post('/auth/register', data: {
        'username': username,
        'fullname': fullname,
        'email': email,
        'password': password,
      });

  Future<Response> getMe() => _dio.get('/auth/me');

  // --- Post Endpoints ---
  Future<Response> getPosts({int page = 1, int limit = 10}) =>
      _dio.get('/posts', queryParameters: {'page': page, 'limit': limit});

  Future<Response> searchPosts(String query, {int page = 1, int limit = 10}) =>
      _dio.get('/posts/search', queryParameters: {'q': query, 'page': page, 'limit': limit});

  Future<Response> getUserPosts(String userId, {int page = 1, int limit = 10}) =>
      _dio.get('/posts/users/$userId', queryParameters: {'page': page, 'limit': limit});

  Future<Response> uploadPost({
    required String filePath,
    required String description,
    List<String> tags = const [],
  }) async {
    final formData = FormData.fromMap({
      'description': description,
      'tags': tags.join(','),
      'media': await MultipartFile.fromFile(filePath),
    });
    return _dio.post('/posts/upload', data: formData);
  }

  Future<Response> likePost(String postId) => _dio.post('/posts/$postId/like');

  Future<Response> getComments(String postId) => _dio.get('/posts/$postId/comments');

  Future<Response> addComment(String postId, String text) => 
      _dio.post('/posts/$postId/comment', data: {'text': text});

  // --- Profile Endpoints ---
  Future<Response> getProfile(String userId) => _dio.get('/posts/users/$userId/profile');
  
  Future<Response> followUser(String userId) => _dio.post('/posts/users/$userId/follow');
}
