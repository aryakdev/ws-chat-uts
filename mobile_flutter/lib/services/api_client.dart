import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  late final Dio dio;
  late final Dio _refreshDio;

  Future<String?>? _refreshFuture;

  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://127.0.0.1:8080';
  }

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

  // Convenience helpers to centralize common request patterns
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, {dynamic data, Options? options}) async {
    return dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path, {dynamic data, Options? options}) async {
    return dio.delete(path, data: data, options: options);
  }

  // Build absolute URL for diagnostics or legacy code that needs it
  String buildUrl(String path) => '${baseUrl.replaceAll(RegExp(r'\/ ? ? ?'), '')}${path.startsWith('/') ? path : '/$path'}';

  // Return headers including authorization when available. Useful for non-dio callers.
  Future<Map<String, String>> authorizedHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final headers = <String, String>{
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<void> init() async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final accessToken = prefs.getString(_accessTokenKey);

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
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
            final newAccessToken = await _refreshAccessToken();
            if (newAccessToken == null || newAccessToken.isEmpty) {
              return handler.next(error);
            }

            final requestOptions = error.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            requestOptions.extra['retried_after_refresh'] = true;

            final retryResponse = await dio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            await clearAuthTokens();
            return handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<void> clearAuthTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Future<String?> _refreshAccessToken() async {
    _refreshFuture ??= _performTokenRefresh();

    try {
      return await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _performTokenRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);

    if (refreshToken == null || refreshToken.isEmpty) {
      await clearAuthTokens();
      return null;
    }

    try {
      final response = await _refreshDio.post(
        '/api/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode != 200) {
        await clearAuthTokens();
        return null;
      }

      final data = response.data;
      final newAccessToken =
          (data['access_token'] ?? data['token'])?.toString() ?? '';
      final newRefreshToken =
          (data['refresh_token'] ?? refreshToken).toString();

      if (newAccessToken.isEmpty) {
        await clearAuthTokens();
        return null;
      }

      await saveAuthTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      return newAccessToken;
    } catch (_) {
      await clearAuthTokens();
      return null;
    }
  }
}