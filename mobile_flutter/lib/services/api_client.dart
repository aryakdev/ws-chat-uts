import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _refreshDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  late final Dio dio;
  late final Dio _refreshDio;

  String? _accessToken;
  String? _refreshToken;

  Future<String?>? _refreshFuture;

  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://127.0.0.1:8080';
  }

  // =========================
  // INIT
  // =========================
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null && _accessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },

        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final isUnauthorized = statusCode == 401;
          final alreadyRetried =
              error.requestOptions.extra['retried_after_refresh'] == true;

          if (!isUnauthorized || alreadyRetried) {
            return handler.next(error);
          }

          try {
            final newToken = await _refreshAccessToken();

            if (newToken == null) {
              await logout();
              return handler.next(error);
            }

            final requestOptions = error.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newToken';
            requestOptions.extra['retried_after_refresh'] = true;

            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          } catch (_) {
            await logout();
            return handler.next(error);
          }
        },
      ),
    );
  }

  // =========================
  // AUTH STORAGE
  // =========================
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _accessToken = accessToken;
    _refreshToken = refreshToken;

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // =========================
  // REFRESH TOKEN
  // =========================
  Future<String?> _refreshAccessToken() async {
    _refreshFuture ??= _performRefresh();

    try {
      return await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _performRefresh() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      await logout();
      return null;
    }

    try {
      final response = await _refreshDio.post(
        '/api/auth/refresh',
        data: {'refresh_token': _refreshToken},
      );

      final data = response.data;

      final newAccessToken = (data['access_token'] ?? data['token'])?.toString();
      final newRefreshToken =
          (data['refresh_token'] ?? _refreshToken).toString();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await logout();
        return null;
      }

      await saveAuthTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      return newAccessToken;
    } catch (_) {
      await logout();
      return null;
    }
  }

  // =========================
  // LOGOUT (SINGLE SOURCE OF TRUTH)
  // =========================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    _accessToken = null;
    _refreshToken = null;
    _refreshFuture = null;

    dio.options.headers.remove('Authorization');

    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // =========================
  // HELPERS
  // =========================
  Future<String?> getAccessToken() async => _accessToken;

  Future<Map<String, String>> authorizedHeaders() async {
    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }
  Future<Response> post(
  String path, {
  dynamic data,
  Options? options,
}) async {
  return dio.post(path, data: data, options: options);
}

Future<Response> get(
  String path, {
  Map<String, dynamic>? queryParameters,
  Options? options,
}) async {
  return dio.get(path, queryParameters: queryParameters, options: options);
}

Future<Response> put(
  String path, {
  dynamic data,
  Options? options,
}) async {
  return dio.put(path, data: data, options: options);
}

Future<Response> delete(
  String path, {
  dynamic data,
  Options? options,
}) async {
  return dio.delete(path, data: data, options: options);
}

  String buildUrl(String path) {
    return '${baseUrl.replaceAll(RegExp(r'\/+'), '')}/${path.replaceFirst(RegExp(r'^/'), '')}';
  }
}