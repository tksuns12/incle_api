import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:incle_api/interceptors.dart';

Dio getClientDioClient(
    {bool needAuthorization = false,
    required String baseUrl,
    required FlutterSecureStorage secureStorage}) {
  final dio = Dio();
  final storage = secureStorage;
  dio.options.baseUrl = baseUrl;
  dio.options.connectTimeout = 30000;
  dio.options.sendTimeout = 30000;
  dio.options.receiveTimeout = 30000;
  if (needAuthorization) {
    dio.interceptors.add(ClientTokenInterceptor(storage: storage, dio: dio));
  }
  dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      request: true,
      error: true));
  return dio;
}

Dio getPartnersDioClient(
    {bool needAuthorization = false,
    required String baseUrl,
    required FlutterSecureStorage secureStorage}) {
  final dio = Dio();
  final storage = secureStorage;
  dio.options.baseUrl = baseUrl;
  dio.options.connectTimeout = 30000;
  dio.options.sendTimeout = 30000;
  dio.options.receiveTimeout = 30000;
  if (needAuthorization) {
    dio.interceptors
        .add(PartnersTokenInterceptor(storage: storage, dio: dio));
  }
  dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      request: true,
      error: true));
  return dio;
}
