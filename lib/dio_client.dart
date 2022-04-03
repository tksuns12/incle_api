import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

Dio getClientDioClient(
    {bool needAuthorization = false,
    required String baseUrl,
    required FlutterSecureStorage secureStorage}) {
  final logger = Logger();
  final _dio = Dio();
  final storage = secureStorage;
  _dio.options.baseUrl = baseUrl;
  if (needAuthorization) {
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      final _userToken = await storage.read(key: 'accessToken');
      options.headers['Authorization'] = 'Bearer $_userToken';
      logger.d('Intercepted, ${options.method} ${options.path}');
      return handler.next(options);
    }, onError: (error, handler) async {
      logger.e('Error occured, ${error.response}');
      if (error.response?.statusCode == 401) {
        final refreshToken = await storage.read(key: 'refreshToken');
        final refreshDio = Dio()
          ..options = BaseOptions(
            baseUrl: 'http://backend.wim.kro.kr:5000/api/v1',
          );
        refreshDio.options.headers['Authorization'] = 'Bearer $refreshToken';
        final response = await refreshDio.post(
          '/refresh',
        );
        if (response.statusCode == 201) {
          storage.write(
              key: 'accessToken', value: response.data['accessToken']);
          storage.write(
              key: 'refreshToken', value: response.data['refreshToken']);
          error.requestOptions.headers['Authorization'] =
              'Bearer ${response.data['accessToken']}';
          final retryReq = await refreshDio.request(error.requestOptions.path,
              options: Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              ));
          return handler.resolve(retryReq);
        } else if (response.statusCode == 401) {
          final id = await storage.read(key: 'id');
          final password = await storage.read(key: 'password');
          final loginDio = Dio()
            ..options =
                BaseOptions(baseUrl: 'http://backend.wim.kro.kr:5000/api/v1');
          final response = await loginDio.post(
            '/login-user',
            data: {'userName': id, 'password': password},
          );
          if (response.statusCode == 201) {
            storage.write(
                key: 'accessToken', value: response.data['accessToken']);
            storage.write(
                key: 'refreshToken', value: response.data['refreshToken']);
            error.requestOptions.headers['Authorization'] =
                'Bearer ${response.data['accessToken']}';
            final retryReq = await loginDio.request(error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ));
            return handler.resolve(retryReq);
          } else {
            throw Exception(response.statusMessage);
          }
        } else {
          throw Exception(response.statusMessage);
        }
      } else {
        return handler.next(error);
      }
    }));
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
  final logger = Logger();
  final _dio = Dio();
  final storage = secureStorage;
  _dio.options.baseUrl = baseUrl;
  if (needAuthorization) {
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      final _userToken = await storage.read(key: 'accessToken');
      options.headers['Authorization'] = 'Bearer $_userToken';
      logger.d('Intercepted, ${options.method} ${options.path}');
      return handler.next(options);
    }, onError: (error, handler) async {
      logger.e('Error occured, ${error.response}');
      if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
        final refreshToken = await storage.read(key: 'refreshToken');
        final refreshDio = Dio()
          ..options = BaseOptions(
            baseUrl: 'http://backend.wim.kro.kr:5000/api/v1',
          )
          ..interceptors.add(InterceptorsWrapper(
            onError: (e, handler) async {
              try {
                final id = await storage.read(key: 'id');
                final password = await storage.read(key: 'password');
                final loginDio = Dio()
                  ..options = BaseOptions(
                      baseUrl: 'http://backend.wim.kro.kr:5000/api/v1');
                final response = await loginDio.post(
                  '/login-partners',
                  data: {'partnersName': id, 'password': password},
                );
                storage.write(
                    key: 'accessToken', value: response.data['accessToken']);
                storage.write(
                    key: 'refreshToken', value: response.data['refreshToken']);
                error.requestOptions.headers['Authorization'] =
                    response.data['accessToken'];
                final retryReq =
                    await loginDio.request(error.requestOptions.path,
                        options: Options(
                          method: error.requestOptions.method,
                          headers: error.requestOptions.headers,
                        ));
                return handler.resolve(retryReq);
              } on DioError catch (e) {
                await storage.deleteAll();
                throw Exception('저장된 로그인 정보에 문제가 있습니다. 다시 로그인 해주세요. msg: $e');
              }
            },
          ));
        refreshDio.options.headers['Authorization'] = 'Bearer $refreshToken';
        final response = await refreshDio.post(
          '/refresh',
        );
        if (response.statusCode == 200) {
          storage.write(
              key: 'accessToken', value: response.data['accessToken']);
          storage.write(
              key: 'refreshToken', value: response.data['refreshToken']);
          error.requestOptions.headers['Authorization'] =
              response.data['accessToken'];
          final retryReq = await refreshDio.request(error.requestOptions.path,
              options: Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              ));
          return handler.resolve(retryReq);
        }
      } else {
        return handler.next(error);
      }
    }));
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
