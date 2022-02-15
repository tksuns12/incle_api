library incle_api;

import 'dart:io';

import 'package:dio/dio.dart';

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
    String? storeAddress,
    String? storePhone,
    String? openTime,
    String? closeTime,
    List<List<bool>>? dayoffs,
    String? storeDescription,
    List<File>? storePictures,
    String? storeName,
    bool? isRestHolidy,
  }) async {
    try {
      final response = await _dio.post(
        '/partners',
        data: {
          'isRestHolidy': isRestHolidy,
          'id': id,
          'password': password,
          'name': name,
          'phone_number': phoneNumber,
          'email': email,
          'owner_name': ownerName,
          'business_number': businessNumber,
          'registration': registration,
          'registration2': registration2,
          'bank': bank,
          'account_number': accountNumber,
          'account_owner': accountOwner,
          'store_categories': storeCategories,
          'store_address': storeAddress,
          'store_phone': storePhone,
          'open_time': openTime,
          'close_time': closeTime,
          'dayoffs': dayoffs,
          'store_description': storeDescription,
          'store_pictures': storePictures,
          'store_name': storeName,
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
    String? storeAddress,
    String? storePhone,
    String? openTime,
    String? closeTime,
    List<List<bool>>? dayoffs,
    String? storeDescription,
    List<File>? storePictures,
    String? storeName,
    bool? isRestHolidy,
  }) async {
    try {
      final response = await _dio.put(
        '/partners',
        options: Options(headers: {
          'Authorization': 'Bearer $_userToken',
        }),
        data: {
          'isRestHolidy': isRestHolidy,
          'id': id,
          'password': password,
          'name': name,
          'phone_number': phoneNumber,
          'email': email,
          'owner_name': ownerName,
          'business_number': businessNumber,
          'registration': registration,
          'registration2': registration2,
          'bank': bank,
          'account_number': accountNumber,
          'account_owner': accountOwner,
          'store_categories': storeCategories,
          'store_address': storeAddress,
          'store_phone': storePhone,
          'open_time': openTime,
          'close_time': closeTime,
          'dayoffs': dayoffs,
          'store_description': storeDescription,
          'store_pictures': storePictures,
          'store_name': storeName,
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

  Future<Map> signin(String id, String password) async {
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
      throw Exception(e.toString());
    }
  }

  Future<Map> getPartnersProfile() async {
    try {
      final response = await _dio.get(
        '/partners',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_userToken',
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

  /// name 패러미터에는 email, id, phone 셋 중 하나만 입력해야 합니다.
  Future<Map> duplicateCheck(String name, String property) async {
    try {
      final response = await _dio.get(
        '/partners/duplicateCheck',
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
}
