import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class PartnersTokenInterceptor implements Interceptor {
  final FlutterSecureStorage storage;
  final Dio dio;
  final logger = Logger(level: Level.debug);

  PartnersTokenInterceptor({
    required this.storage,
    required this.dio,
  });
  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    logger.e('Error occured, ${err.response}');
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      final refreshToken = await storage.read(key: 'refreshToken');
      final refreshDio = Dio();
      refreshDio.options = BaseOptions(
        baseUrl: 'http://backend.wim.kro.kr:5000/api/v1',
      );
      refreshDio.options.headers['Authorization'] = 'Bearer $refreshToken';
      refreshDio.interceptors
          .add(InterceptorsWrapper(onError: (innerErr, handler) async {
        if (innerErr.response!.statusCode == 401 ||
            innerErr.response!.statusCode == 403) {
          final id = await storage.read(key: 'id');
          final password = await storage.read(key: 'password');

          final signinDio = Dio();
          signinDio.options = BaseOptions(
            baseUrl: 'http://backend.wim.kro.kr:5000/api/v1',
          );
          try {
            final loginResponse = await signinDio.post('/login-partners',
                data: {'partnersName': id, 'password': password});
            if (loginResponse.statusCode == 201) {
              await storage.write(
                  key: 'accessToken', value: loginResponse.data['accessToken']);
              await storage.write(
                  key: 'refreshToken',
                  value: loginResponse.data['refreshToken']);

              err.requestOptions.headers['Authorization'] =
                  'Bearer ${loginResponse.data['accessToken']}';

              final innerRetryReq = await dio.request(err.requestOptions.path,
                  options: Options(
                    method: err.requestOptions.method,
                    headers: err.requestOptions.headers,
                  ));
              handler.resolve(innerRetryReq);
            }
          } catch (e) {
            logger.e('Inner Intercedptor Error occured, $e');
            handler.next(err);
          }
        }
      }));

      final response = await refreshDio.post(
        '/refresh',
      );
      if (response.statusCode == 201) {
        storage.write(key: 'accessToken', value: response.data['accessToken']);
        storage.write(
            key: 'refreshToken', value: response.data['refreshToken']);
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
      storage.deleteAll();
      return handler.next(err);
    }
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final _userToken = await storage.read(key: 'accessToken');
    options.headers['Authorization'] = 'Bearer $_userToken';
    logger.d('Intercepted, ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {}
}

class ClientTokenInterceptor implements Interceptor {
  final FlutterSecureStorage storage;
  final Dio dio;
  ClientTokenInterceptor({
    required this.storage,
    required this.dio,
  });
  final logger = Logger(level: Level.debug);
  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    logger.e('Error occured, ${err.response}');
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      final refreshToken = await storage.read(key: 'refreshToken');
      final refreshDio = Dio();
      refreshDio.options = BaseOptions(
        baseUrl: 'http://backend.wim.kro.kr:5000/api/v1',
      );
      refreshDio.options.headers['Authorization'] = 'Bearer $refreshToken';
      refreshDio.interceptors
          .add(InterceptorsWrapper(onError: (innerErr, handler) async {
        if (innerErr.response!.statusCode == 401 ||
            innerErr.response!.statusCode == 403) {
          final id = await storage.read(key: 'id');
          final password = await storage.read(key: 'password');

          final signinDio = Dio();
          signinDio.options = BaseOptions(
            baseUrl: 'http://backend.wim.kro.kr:5000/api/v1',
          );
          try {
            final loginResponse = await signinDio.post('/login-user',
                data: {'userName': id, 'password': password});
            if (loginResponse.statusCode == 201) {
              await storage.write(
                  key: 'accessToken', value: loginResponse.data['accessToken']);
              await storage.write(
                  key: 'refreshToken',
                  value: loginResponse.data['refreshToken']);

              err.requestOptions.headers['Authorization'] =
                  'Bearer ${loginResponse.data['accessToken']}';

              final innerRetryReq = await dio.request(err.requestOptions.path,
                  options: Options(
                    method: err.requestOptions.method,
                    headers: err.requestOptions.headers,
                  ));
              handler.resolve(innerRetryReq);
            }
          } catch (e) {
            logger.e('Inner Intercedptor Error occured, $e');
            handler.next(err);
          }
        }
      }));

      final response = await refreshDio.post(
        '/refresh',
      );
      if (response.statusCode == 201) {
        storage.write(key: 'accessToken', value: response.data['accessToken']);
        storage.write(
            key: 'refreshToken', value: response.data['refreshToken']);
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
      storage.deleteAll();
      return handler.next(err);
    }
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final _userToken = await storage.read(key: 'accessToken');
    options.headers['Authorization'] = 'Bearer $_userToken';
    logger.d('Intercepted, ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // TODO: implement onResponse
  }
}
