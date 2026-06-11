import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'storage_io.dart' if (dart.library.html) 'storage_web.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  late final Dio dio;
  late final Dio refreshDio;

  String? accessToken;
  String? refreshToken;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'accept': 'application/json',
      },
    ));

    refreshDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  String get baseUrl => 'http://13.212.39.206:8080';

  Future<void> init() async {
    accessToken = await storageGetString(_accessTokenKey);
    refreshToken = await storageGetString(_refreshTokenKey);
    if (accessToken != null && accessToken!.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $accessToken';
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    await storageSetString(_accessTokenKey, accessToken);
    await storageSetString(_refreshTokenKey, refreshToken);
    dio.options.headers['Authorization'] = 'Bearer $accessToken';
  }

  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
    dio.options.headers.remove('Authorization');
    await storageRemove(_accessTokenKey);
    await storageRemove(_refreshTokenKey);
  }

  Future<Response> get(String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(String path, {
    dynamic data,
    Options? options,
  }) => dio.post(path, data: data, options: options);

  Future<Response> put(String path, {
    dynamic data,
    Options? options,
  }) => dio.put(path, data: data, options: options);

  Future<Response> delete(String path, {
    dynamic data,
    Options? options,
  }) => dio.delete(path, data: data, options: options);
}