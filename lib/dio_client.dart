import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:incle_api/interceptors.dart';

Dio getClientDioClient(
    {bool needAuthorization = false,
    required String baseUrl,
    required FlutterSecureStorage secureStorage}) {
  final _dio = Dio();
  final storage = secureStorage;
  _dio.options.baseUrl = baseUrl;
  _dio.options.connectTimeout = 10000;
  _dio.options.sendTimeout = 10000;
  _dio.options.receiveTimeout = 10000;
  if (needAuthorization) {
    _dio.interceptors.add(ClientTokenInterceptor(storage: storage, dio: _dio));
  }
  _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      request: true,
      error: true));
  return _dio;
}

Dio getPartnersDioClient(
    {bool needAuthorization = false,
    required String baseUrl,
    required FlutterSecureStorage secureStorage}) {
  final _dio = Dio();
  final storage = secureStorage;
  _dio.options.baseUrl = baseUrl;
  _dio.options.connectTimeout = 10000;
  _dio.options.sendTimeout = 10000;
  _dio.options.receiveTimeout = 10000;
  if (needAuthorization) {
    _dio.interceptors
        .add(PartnersTokenInterceptor(storage: storage, dio: _dio));
  }
  _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      request: true,
      error: true));
  return _dio;
}
