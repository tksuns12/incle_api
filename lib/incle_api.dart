library incle_api;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class InclePartnersAPI {
  late Dio dio;
  late FlutterSecureStorage storage;

  static final InclePartnersAPI _instance = InclePartnersAPI._internal();

  InclePartnersAPI._internal();

  factory InclePartnersAPI([FlutterSecureStorage? storage]) {
    if (storage == null) {
      _instance.storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accountName: 'InclePartners',
            accessibility: IOSAccessibility.first_unlock,
          ));
    } else {
      _instance.storage = storage;
    }
    _instance.dio = Dio();
    _instance.dio.options =
        BaseOptions(baseUrl: 'https://incle.api.wim.kro.kr/api/v1');
    _instance.dio.interceptors.addAll([
      InterceptorsWrapper(onRequest: (options, handler) async {
        print('Intercepted, ${options.method} ${options.path}');
        if (options.headers['Authorization'] != null) {
          final _userToken = await _instance.storage.read(key: 'token');
          options.headers['Authorization'] = 'Bearer $_userToken';
        }
        return handler.next(options);
      }, onError: (error, handler) async {
        print('Error occured, ${error.response}');
        if (error.response?.statusCode == 412) {
          final id = await _instance.storage.read(key: 'id');
          final password = await _instance.storage.read(key: 'password');
          try {
            final tempDio = Dio()
              ..options =
                  BaseOptions(baseUrl: 'https://incle.api.wim.kro.kr/api/v1');
            final response = await tempDio.post(
              '/partners/login',
              data: {
                'id': id,
                'password': password,
              },
            );
            if (response.statusCode == 200) {
              _instance.storage
                  .write(key: 'token', value: response.data['data']);
              return response.data;
            } else {
              throw Exception(response.statusMessage);
            }
          } catch (e) {
            rethrow;
          }
        } else {
          throw Exception(error.response);
        }
      }),
      LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        error: true,
      ),
    ]);

    return _instance;
  }

  Future<bool> isSignedIn() async {
    return (await storage.read(key: 'id')) != null &&
        (await storage.read(key: 'password')) != null;
  }

  Future<void> signout() async {
    await storage.deleteAll();
  }

  Future<Map> signup({
    String? id,
    String? password,
    String? name,
    String? phoneNumber,
    String? email,
    String? ownerName,
    String? businessNumber,
    File? registration,
    File? registration2,
    String? bank,
    String? accountNumber,
    String? accountOwner,
    String? storeCategories,
    String? storeAddress1,
    String? storeAddress2,
    String? storePhone,
    String? openTime,
    String? closeTime,
    List<List<bool>>? dayoffs,
    String? storeDescription,
    List<File>? storePictures,
    String? storeName,
    bool? isRestHolidy,
    double? latitude,
    double? longitude,
    String? postCode,
  }) async {
    try {
      final formData = FormData.fromMap({
        'isRestHoliday': isRestHolidy,
        'id': id,
        'password': password,
        'name': storeName,
        'ownerPhone': phoneNumber,
        'email': email,
        'ownerName': name,
        'businessNumber': businessNumber,
        'accountBank': bank,
        'accountNumber': accountNumber,
        'accountName': accountOwner,
        'targetGender': storeCategories,
        'location': storeAddress1,
        'locationDetail': storeAddress2,
        'postNumber': postCode,
        'phone': storePhone,
        'startDate': openTime,
        'endDate': closeTime,
        'closedDays': '"closedDays":${jsonEncode(dayoffs)}',
        'desc': storeDescription,
        'latitude': latitude,
        'longitude': longitude,
      });
      for (var picture in storePictures!) {
        formData.files.add(MapEntry(
            'storeImages',
            await MultipartFile.fromFile(picture.path,
                filename: picture.path.split('/').last)));
      }
      formData.files.add(MapEntry(
          'businessReport',
          await MultipartFile.fromFile(registration!.path,
              filename: registration.path.split('/').last)));
      formData.files.add(MapEntry(
          'businessRegistration',
          await MultipartFile.fromFile(registration2!.path,
              filename: registration2.path.split('/').last)));
      dio.options.contentType = 'multipart/form-data';
      final response = await dio.post(
        '/partners',
        data: formData,
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  updateProfile({
    String? id,
    String? password,
    String? name,
    String? phoneNumber,
    String? email,
    String? ownerName,
    String? businessNumber,
    dynamic registration,
    dynamic registration2,
    String? bank,
    String? accountNumber,
    String? accountOwner,
    String? storeCategories,
    String? storeAddress1,
    String? storeAddress2,
    String? storePhone,
    String? openTime,
    String? closeTime,
    List<List<bool>>? dayoffs,
    String? storeDescription,
    List? storePictures,
    String? storeName,
    bool? isRestHolidy,
    double? latitude,
    double? longitude,
    String? postCode,
    dynamic profilePicture,
  }) async {
    try {
      dio.options.headers['Authorization'] = '';
      final formData = FormData.fromMap({
        'isRestHoliday': isRestHolidy,
        'id': id,
        'password': password,
        'ownerPhone': phoneNumber,
        'email': email,
        'ownerName': ownerName,
        'businessNumber': businessNumber,
        'accountBank': bank,
        'accountNumber': accountNumber,
        'accountName': accountOwner,
        'targetGender': storeCategories,
        'location': storeAddress1,
        'locationDetail': storeAddress2,
        'postNumber': postCode,
        'phone': storePhone,
        'startDate': openTime,
        'endDate': closeTime,
        'closedDays': '"closedDays":${jsonEncode(dayoffs)}',
        'name': storeName,
        'latitude': latitude,
        'longitude': longitude,
      });
      for (final picture in storePictures!) {
        if (picture is File) {
          formData.files.add(MapEntry(
              'storeImages',
              MultipartFile.fromFileSync(picture.path,
                  filename: picture.path.split('/').last)));
        } else {
          final d = Dio();
          final direc = await getTemporaryDirectory();
          final path = direc.path;
          final res = await d.download(picture,
              path + '/storeImage${storePictures.indexOf(picture)}.jpg');
          final data = res.data;

          return MapEntry(
              'storeImages',
              MultipartFile.fromFileSync(res.data.path,
                  filename: res.data.path.split('/').last));
        }
      }
      if (registration is File) {
        formData.files.add(MapEntry(
            'businessReport',
            MultipartFile.fromFileSync(registration.path,
                filename: registration.path.split('/').last)));
      }
      if (registration2 is File) {
        formData.files.add(MapEntry(
            'businessRegistration',
            MultipartFile.fromFileSync(registration2.path,
                filename: registration2.path.split('/').last)));
      }
      if (profilePicture is File) {
        formData.files.add(MapEntry(
            'profile',
            MultipartFile.fromFileSync(profilePicture.path,
                filename: profilePicture.path.split('/').last)));
      }
      final response = await dio.put(
        '/partners',
        data: formData,
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isApproved() async {
    final id = await storage.read(key: 'id');
    final password = await storage.read(key: 'password');
    final response = await dio.post(
      '/partners/login',
      data: {
        'id': id,
        'password': password,
      },
    );
    return response.statusMessage != '허가되지 않은 파트너스';
  }

  Future<Map> login(String id, String password) async {
    try {
      final response = await dio.post(
        '/partners/login',
        data: {
          'id': id,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        storage.write(key: 'id', value: id);
        storage.write(key: 'password', value: password);
        storage.write(key: 'token', value: response.data['data']);
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> getPartnersProfile() async {
    try {
      dio.options.headers['Authorization'] = '';
      final response = await dio.get(
        '/partners',
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> deleteAccount() async {
    try {
      dio.options.headers['Authorization'] = '';
      final response = await dio.delete(
        '/partners',
      );
      if (response.statusCode == 200) {
        storage.delete(key: 'token');
        storage.delete(key: 'id');
        storage.delete(key: 'password');
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> findPasswordAllow(
      {required String email,
      required String phone,
      required String name}) async {
    try {
      final response = await dio.post(
        '/partners/find/password/allow',
        data: {
          'email': email,
          'phone': phone,
          'name': name,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> finidPassword(String code, String password) async {
    try {
      final response = await dio.post(
        '/partners/find/password',
        data: {
          'code': code,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> findId(String email, String name, String phone) async {
    try {
      final response = await dio.post(
        '/partners/find/id',
        data: {
          'email': email,
          'name': name,
          'phone': phone,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// name 패러미터에는 email, id, phone 셋 중 하나만 입력해야 합니다.
  Future<Map> duplicateCheck(String name, String property) async {
    try {
      final response = await dio.get(
        '/partners/duplicate',
        queryParameters: {
          'name': name,
          'property': property,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map> sendVerifyNum(String phoneNumber) async {
    try {
      final response = await dio.post(
        '/partners/verification',
        queryParameters: {
          'phone': phoneNumber,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map> checkVerifyNum(String phoneNumber, String code) async {
    try {
      final response = await dio.post(
        '/partners/verification',
        queryParameters: {
          'phone': phoneNumber,
          'code': code,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map> createCoupon(String name, int price, int condition,
      [DateTime? limitDate]) async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.post(
        '/partners/coupon',
        data: {
          'name': name,
          'price': price,
          'condition': condition,
          'limit_date':
              '${limitDate?.year.toString().substring(2, 4)}.${limitDate?.month.toString().padLeft(2, '0')}.${limitDate?.day.toString().padLeft(2, '0')}',
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map> getCouponList() async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.get(
        '/partners/coupon/list',
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map> deleteCoupon(String couponID) async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.delete(
        '/partners/coupon/$couponID',
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map> getDeliver() async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.get(
        '/partners/deliver',
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> updateDeliver(
      {required Map<int, int> deliveryConditions,
      required int freeCondition}) async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.post(
        '/partners/deliver',
        data: {
          'deliver': deliveryConditions.entries
              .map((e) => {'km': e.key, 'price': e.value})
              .toList(),
          'free': freeCondition,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> unpausePartners() async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.post(
        '/partners/unpause',
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> pausePartners(TimeOfDay startTime, TimeOfDay endTime) async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.post(
        '/partners/pause',
        data: {
          'pause_start_date':
              '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
          'pause_end_date':
              '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isServerHealthy() async {
    try {
      final response = await dio.get('/health');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> holidayCheck(String year, String month, String day) async {
    try {
      final response = await dio.get(
        '/holiday',
        queryParameters: {
          'year': year,
          'month': month,
          'date': day,
        },
      );
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> uploadProduct(
      {required String name,
      required String price,
      required bool todayGet,
      required List<File> images,
      required String description,
      required int modelHeight,
      required int modelWeight,
      required String modelNormalSize,
      required String modelSize,
      required Map<String, List<Map<String, dynamic>>> options,
      required List<String> cody}) async {
    dio.options.headers['Authorization'] = '';
    try {
      final formData = FormData.fromMap({
        'name': name,
        'price': price,
        'todayGet': todayGet,
        'desc': description,
        'modelHeight': modelHeight,
        'modelWeight': modelWeight,
        'modelSize': modelSize,
        'modelNormalSize': modelNormalSize,
        'options': jsonEncode(options),
        'cody': cody,
      });
      for (var image in images) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }
      final response = await dio.post('/partners/product', data: formData);
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> getPartnersProductList(
      {bool recommendedOnly = false, bool discountOnly = false}) async {
    assert((recommendedOnly || discountOnly) ||
        (!recommendedOnly || !discountOnly));
    dio.options.headers['Authorization'] = '';
    try {
      Map<String, dynamic>? _queryParameter;
      if (recommendedOnly) {
        _queryParameter = {'option': 'owners_recommended'};
      } else if (discountOnly) {
        _queryParameter = {'option': 'discount_price'};
      }
      final response =
          await dio.get('/partners/product', queryParameters: _queryParameter);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> updateProduct(
      {required String uid,
      required String name,
      required String price,
      required bool todayGet,
      required List images,
      required String description,
      required int modelHeight,
      required int modelWeight,
      required String modelNormalSize,
      required String modelSize,
      required Map<String, List<Map<String, dynamic>>> options,
      required List<String> cody}) async {
    dio.options.headers['Authorization'] = '';
    try {
      final formData = FormData.fromMap({
        'name': name,
        'price': price,
        'todayGet': todayGet,
        'desc': description,
        'modelHeight': modelHeight,
        'modelWeight': modelWeight,
        'modelSize': modelSize,
        'modelNormalSize': modelNormalSize,
        'options': jsonEncode(options),
        'cody': cody,
      });
      for (var image in images) {
        if (image is File) {
          formData.files.add(
            MapEntry(
              'images',
              await MultipartFile.fromFile(
                image.path,
                filename: image.path.split('/').last,
              ),
            ),
          );
        } else if (image is String) {
          final d = Dio();
          final filePath =
              '${(await getTemporaryDirectory()).path}/temp_product${images.indexOf(image)}.jpg';
          await d.download(image, filePath);
          formData.files.add(
            MapEntry(
              'images',
              await MultipartFile.fromFile(
                filePath,
                filename: image.split('/').last,
              ),
            ),
          );
        }
      }
      final response = await dio.put('/partners/product/$uid', data: formData);
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> deleteProduct({required String uid}) async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.delete('/partners/product/$uid');
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  soldoutProduct({required String uid, required List<String> options}) async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.put(
        '/partners/product/soldout/$uid',
        data: {
          'options': options,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> addProductOwnersRecommend({required String uid}) async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.put(
        '/partners/product/ownersrecommended/$uid',
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> addProductDiscount(
      {required String uid, required int discountedPrice}) async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.put('/partners/product/discount/$uid',
          queryParameters: {'price': discountedPrice});
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> deleteProductOwnersRecommended({required String uid}) async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.delete(
        '/partners/product/ownersrecommended/$uid',
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> deleteProductDiscount({required String uid}) async {
    dio.options.headers['Authorization'] = '';
    try {
      final response = await dio.delete(
        '/partners/product/discount/$uid',
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
