import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as flutter_secure_storage;
import 'package:logger/logger.dart';

class PartnersTokenInterceptor extends Interceptor {
  final flutter_secure_storage.FlutterSecureStorage storage;
  final Dio dio;
  final logger = Logger(level: Level.debug);

  PartnersTokenInterceptor({
    required this.storage,
    required this.dio,
  });
  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    logger.e('Error occured, ${err.response}');
    if (err.response?.statusCode == 401) {
      final refreshToken = await storage
          .read(key: 'refreshToken')
          .timeout(const Duration(seconds: 10));
      final refreshDio = Dio();
      refreshDio.options = BaseOptions(
        baseUrl: 'http://backend.wim.kro.kr:5000/api/v1',
      );
      refreshDio.options.headers['Authorization'] = 'Bearer $refreshToken';
      refreshDio.interceptors.addAll([
        InterceptorsWrapper(onError: (innerErr, innerHandler) async {
          if (innerErr.response?.statusCode == 401 ||
              innerErr.response?.statusCode == 403) {
            await storage.deleteAll();
          }
          handler.next(innerErr);
        }),
        LogInterceptor(
            error: true,
            request: true,
            requestBody: true,
            responseBody: true,
            responseHeader: true,
            requestHeader: true)
      ]);

      final response = await refreshDio.post(
        '/refresh',
      );
      if (response.statusCode == 201) {
        await storage
            .write(key: 'accessToken', value: response.data['accessToken'])
            .timeout(const Duration(seconds: 10));
        await storage
            .write(key: 'refreshToken', value: response.data['refreshToken'])
            .timeout(const Duration(seconds: 10));
        err.requestOptions.headers['Authorization'] =
            'Bearer ${response.data['accessToken']}';
        final retryReq = await dio.request(err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ));
        return handler.resolve(retryReq);
      }
    } else {
      return handler.next(err);
    }
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final _userToken = await storage
        .read(key: 'accessToken')
        .timeout(const Duration(seconds: 10));
    options.headers['Authorization'] = 'Bearer $_userToken';
    logger.d('Intercepted, ${options.method} ${options.path}');
    handler.next(options);
  }
}

class ClientTokenInterceptor extends Interceptor {
  final flutter_secure_storage.FlutterSecureStorage storage;
  final Dio dio;
  ClientTokenInterceptor({
    required this.storage,
    required this.dio,
  });
  final logger = Logger(level: Level.debug);

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    logger.e('Error occured, ${err.response}');
    if (err.response?.statusCode == 401) {
      final refreshToken = await storage
          .read(key: 'refreshToken')
          .timeout(const Duration(seconds: 10));
      final refreshDio = Dio();
      refreshDio.options = BaseOptions(
        baseUrl: 'http://backend.wim.kro.kr:5000/api/v1',
      );
      refreshDio.options.headers['Authorization'] = 'Bearer $refreshToken';
      refreshDio.interceptors.addAll([
        InterceptorsWrapper(onError: (innerErr, innerHandler) async {
          if (innerErr.response?.statusCode == 401 ||
              innerErr.response?.statusCode == 403) {
            await storage.deleteAll();
          }
          handler.next(innerErr);
        }),
        LogInterceptor(
            error: true,
            request: true,
            requestBody: true,
            responseBody: true,
            responseHeader: true,
            requestHeader: true)
      ]);

      final response = await refreshDio.post(
        '/refresh',
      );
      if (response.statusCode == 201) {
        await storage
            .write(key: 'accessToken', value: response.data['accessToken'])
            .timeout(const Duration(seconds: 10));
        await storage
            .write(key: 'refreshToken', value: response.data['refreshToken'])
            .timeout(const Duration(seconds: 10));
        err.requestOptions.headers['Authorization'] =
            'Bearer ${response.data['accessToken']}';
        final retryReq = await dio.request(err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ));
        return handler.resolve(retryReq);
      }
    } else {
      return handler.next(err);
    }
  }
}
