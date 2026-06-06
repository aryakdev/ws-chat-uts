import 'package:dio/dio.dart';
import 'package:mobile_flutter/services/api_client_services.dart';

class ApiController {
  final ApiClient _client;

  ApiController(this._client);

  Future<String?>? _refreshFuture;

  // =========================
  // INIT - pasang interceptor
  // =========================
  void init() {
    _client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  // =========================
  // INTERCEPTORS
  // =========================
  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _client.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
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

      final response = await _client.dio.fetch(requestOptions);
      return handler.resolve(response);
    } catch (_) {
      await logout();
      return handler.next(error);
    }
  }

  // =========================
  // REFRESH LOGIC
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
    final refreshToken = _client.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      await logout();
      return null;
    }

    try {
      final response = await _client.refreshDio.post(
        '/api/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final data = response.data;
      final newAccessToken =
          (data['access_token'] ?? data['token'])?.toString();
      final newRefreshToken =
          (data['refresh_token'] ?? refreshToken).toString();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await logout();
        return null;
      }

      await _client.saveTokens(
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
  // LOGOUT
  // =========================
  Future<void> logout() async {
    _refreshFuture = null;
    await _client.clearTokens();
  }
}