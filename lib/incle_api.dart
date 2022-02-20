library incle_api;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class IncleAPI {
  static String _userToken = '';
  static late Dio _dio;

  static initialize(String? userToken) {
    if (userToken != null) {
      _userToken = userToken;
    }
    _dio = Dio(BaseOptions(baseUrl: 'https://incle.api.wim.kro.kr/api/v1'));
  }

  static Future<Map> signup({
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
        'name': name,
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
        'closedDays': dayoffs,
        'store_description': storeDescription,
        'store_name': storeName,
        'latitude': latitude,
        'longitude': longitude,
      });

      formData.files.addAll(storePictures!.map((e) => MapEntry(
          'storeImages',
          MultipartFile.fromFileSync(e.path,
              filename: e.path.split('/').last))));
      formData.files.add(MapEntry(
          'businessReport',
          MultipartFile.fromFileSync(registration!.path,
              filename: registration.path.split('/').last)));
      formData.files.add(MapEntry(
          'businessRegistration',
          MultipartFile.fromFileSync(registration2!.path,
              filename: registration2.path.split('/').last)));

      final response =
          await _dio.post('/partners', data: formData, options: Options());
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  static updateProfile({
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
        'name': name,
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
        'closedDays': dayoffs,
        'store_description': storeDescription,
        'store_name': storeName,
        'latitude': latitude,
        'longitude': longitude,
      });

      formData.files.addAll(storePictures!.map((e) => MapEntry(
          'storeImages',
          MultipartFile.fromFileSync(e.path,
              filename: e.path.split('/').last))));
      formData.files.add(MapEntry(
          'businessReport',
          MultipartFile.fromFileSync(registration!.path,
              filename: registration.path.split('/').last)));
      formData.files.add(MapEntry(
          'businessRegistration',
          MultipartFile.fromFileSync(registration2!.path,
              filename: registration2.path.split('/').last)));
      final response = await _dio.put(
        '/partners',
        options: Options(headers: {
          'Token': 'Bearer $_userToken',
        }),
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

  Future<Map> login(String id, String password) async {
    try {
      final response = await _dio.post(
        '/partners/login',
        data: {
          'id': id,
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

  Future<Map> getPartnersProfile() async {
    try {
      final response = await _dio.get(
        '/partners',
        options: Options(
          headers: {
            'Token': 'Bearer $_userToken',
          },
        ),
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
      final response = await _dio.delete(
        '/partners',
        options: Options(
          headers: {
            'Token': 'Bearer $_userToken',
          },
        ),
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

  Future<Map> findPasswordAllow(String email, String phone, String name) async {
    try {
      final response = await _dio.post(
        '/partners/find/password/allow',
        data: {
          'email': email,
          'phone': phone,
          'name': name,
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

  Future<Map> finidPassword(String code, String password) async {
    try {
      final response = await _dio.post(
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
      final response = await _dio.post(
        '/partners/find/id',
        data: {
          'email': email,
          'name': name,
          'phone': phone,
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

  /// name 패러미터에는 email, id, phone 셋 중 하나만 입력해야 합니다.
  Future<Map> duplicateCheck(String name, String property) async {
    try {
      final response = await _dio.get(
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
      final response = await _dio.post(
        '/partners/verification',
        queryParameters: {
          'phone': phoneNumber,
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

  Future<Map> checkVerifyNum(String phoneNumber, String code) async {
    try {
      final response = await _dio.post(
        '/partners/verification',
        queryParameters: {
          'phone': phoneNumber,
          'code': code,
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

  Future<Map> createCoupon(
      String name, int price, int condition, DateTime limitDate) async {
    try {
      final response = await _dio.post(
        '/partners/coupon',
        data: {
          'name': name,
          'price': price,
          'condition': condition,
          'limit_date':
              '${limitDate.year.toString().substring(2, 4)}.${limitDate.month.toString().padLeft(2, '0')}.${limitDate.day.toString().padLeft(2, '0')}',
        },
        options: Options(
          headers: {
            'Token': 'Bearer $_userToken',
          },
        ),
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
    try {
      final response = await _dio.get(
        '/partners/coupon/list',
        options: Options(
          headers: {
            'Token': 'Bearer $_userToken',
          },
        ),
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
    try {
      final response = await _dio.delete(
        '/partners/coupon',
        queryParameters: {
          'partners_coupon_uid': couponID,
        },
        options: Options(
          headers: {
            'Token': 'Bearer $_userToken',
          },
        ),
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

  Future<Map> getDeliver() async {
    try {
      final response = await _dio.get(
        '/partners/deliver',
        options: Options(
          headers: {
            'Token': 'Bearer $_userToken',
          },
        ),
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

  Future<Map> updateDeliver(
      List<Map<String, int>> deliveryConditions, int freeCondition) async {
    try {
      final response = await _dio.post('/partners/deliver',
          data: {
            'delivery_conditions': deliveryConditions,
            'free_condition': freeCondition,
          },
          options: Options(
            headers: {
              'Token': 'Bearer $_userToken',
            },
          ));
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> unpausePartners() async {
    try {
      final response = await _dio.post(
        '/partners/unpause',
        options: Options(
          headers: {
            'Token': 'Bearer $_userToken',
          },
        ),
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

  Future<Map> pausePartners(TimeOfDay startTime, TimeOfDay endTime) async {
    try {
      final response = await _dio.post(
        '/partners/pause',
        data: {
          'pause_start_date':
              '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
          'pause_end_date':
              '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
        },
        options: Options(
          headers: {
            'Token': 'Bearer $_userToken',
          },
        ),
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

  Future<bool> isServerHealthy() async {
    try {
      final response = await _dio.get('/health');
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
      final response = await _dio.get(
        '/partners/holiday',
        queryParameters: {
          'year': year,
          'month': month,
          'date': day,
        },
      );
      if (response.statusCode == 200) {
        return response.data['is_holiday'];
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
