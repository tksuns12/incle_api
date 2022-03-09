library incle_api;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:incle_api/dio_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class InclePartnersAPI {
  final baseUrl = "https://incle.api.wim.kro.kr/api/v1/partners";
  final FlutterSecureStorage storage;

  InclePartnersAPI(this.storage);

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
      final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
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
        '',
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
      final dio = getDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
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

      if (registration is File){
        formData.files.add(MapEntry(
            'businessReport',
            await MultipartFile.fromFile(registration.path,
                filename: registration.path.split('/').last)));
      }
      if (registration2 is File){
        formData.files.add(MapEntry(
            'businessRegistration',
            await MultipartFile.fromFile(registration2.path,
                filename: registration2.path.split('/').last)));
      }

      if (profilePicture is File) {
        formData.files.add(MapEntry(
            'profile',
            await MultipartFile.fromFile(profilePicture.path,
                filename: profilePicture.path.split('/').last)));
      }
      

      for (final picture in storePictures!) {
        if (picture is File) {
          formData.files.add(MapEntry(
              'storeImages',
              MultipartFile.fromFileSync(picture.path,
                  filename: picture.path.split('/').last)));
        } else {
          final res = await http.Client().get(picture);
          final direc = await getTemporaryDirectory();
          final path =
              direc.path + '/storeImage${storePictures.indexOf(picture)}.jpg';
          await File(path).writeAsBytes(res.bodyBytes);

          return MapEntry('storeImages',
              MultipartFile.fromFileSync(path, filename: path.split('/').last));
        }
      }
      final response = await dio.put(
        '',
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
    final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
    final id = await storage.read(key: 'id');
    final password = await storage.read(key: 'password');
    final response = await dio.post(
      '/login',
      data: {
        'id': id,
        'password': password,
      },
    );
    return response.statusMessage != '허가되지 않은 파트너스';
  }

  Future<Map> login(String id, String password) async {
    final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/login',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.delete(
        '',
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
    final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/find/password/allow',
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
    final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/find/password',
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
    final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/find/id',
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
    final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get(
        '/duplicate',
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
    final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/verification',
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
    final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/verification',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.post(
        '/coupon',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/coupon/list',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.delete(
        '/coupon/$couponID',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/deliver',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.post(
        '/deliver',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.post(
        '/unpause',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.post(
        '/pause',
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
      final dio = getDioClient(
          baseUrl: 'https://incle.api.wim.kro.kr/api/v1', secureStorage: storage);
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
    final dio = getDioClient(
        baseUrl: 'https://incle.api.wim.kro.kr/api/v1', secureStorage: storage);
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
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
      final response = await dio.post('/product', data: formData);
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      Map<String, dynamic>? _queryParameter;
      if (recommendedOnly) {
        _queryParameter = {'option': 'owners_recommended'};
      } else if (discountOnly) {
        _queryParameter = {'option': 'discount_price'};
      }
      final response =
          await dio.get('/product', queryParameters: _queryParameter);
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    
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
      final response = await dio.put('/product/$uid', data: formData);
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.delete('/product/$uid');
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.put(
        '/product/soldout/$uid',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.put(
        '/product/ownersrecommended/$uid',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.put('/product/discount/$uid',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.delete(
        '/product/ownersrecommended/$uid',
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
    final dio = getDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.delete(
        '/product/discount/$uid',
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
