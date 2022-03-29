part of 'incle_api.dart';

class IncleClientAPI {
  final baseUrl = "http://backend.wim.kro.kr:5000/api/v1";
  final FlutterSecureStorage storage;

  IncleClientAPI(this.storage);

  //
  // Auth
  //

  Future<Map<String, dynamic>> signin(
      {required String id, required String password}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: false);
      final res = await dio
          .post('/login-user', data: {'userName': id, 'password': password});
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signup(
      {required String id,
      required String password,
      required String name,
      required String nickname,
      required String phoneNumber,
      required String gender,
      required DateTime birth,
      required String email,
      required File profileImage}) async {
    try {
      final dio = getClientDioClient(baseUrl: baseUrl, secureStorage: storage);
      final formData = FormData.fromMap({
        'userName': id,
        'password': password,
        'name': name,
        'displayName': nickname,
        'phone': phoneNumber,
        'gender': gender,
        'birth':
            '${birth.year.toString().substring(0, 2)}${birth.month.toString().padLeft(2, '0')}${birth.day.toString().padLeft(2, '0')}',
        'email': email,
      });
      formData.files.add(MapEntry(
          'userProfile',
          await MultipartFile.fromFile(profileImage.path,
              filename: profileImage.path.split('/').last)));
      final res = await dio.post('/users', data: formData);
      if (res.statusCode == 201) {
        return res.data;
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> editUserInfo({
    required String password,
    required String name,
    required String displayName,
    required String phoneNumber,
    required File profileImage,
  }) async {
    try {
      final dio = getClientDioClient(baseUrl: baseUrl, secureStorage: storage);
      final formData = FormData.fromMap({
        'password': password,
        'name': name,
        'displayName': displayName,
        'phone': phoneNumber,
      });
      formData.files.add(MapEntry(
          'userProfile',
          await MultipartFile.fromFile(profileImage.path,
              filename: profileImage.path.split('/').last)));
      final res = await dio.patch('/users', data: formData);
      if (res.statusCode == 200) {
        return res.data;
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> findID({required String phoneNumber}) async {
    try {
      final dio = getClientDioClient(baseUrl: baseUrl, secureStorage: storage);
      final res =
          await dio.post('/users/username', data: {'phone': phoneNumber});
      if (res.statusCode == 201) {
        return res.data;
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> findPassword(
      {required String id, required String email}) async {
    try {
      final dio = getClientDioClient(baseUrl: baseUrl, secureStorage: storage);
      final res = await dio
          .post('/users/password', data: {'userName': id, 'email': email});
      if (res.statusCode == 201) {
        return res.data;
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final res = await dio.get('/users/profile');
      if (res.statusCode == 200) {
        return res.data;
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkDuplicate(
      {String? userName,
      String? phoneNumber,
      String? email}) async {
    try {
      final dio = getClientDioClient(baseUrl: baseUrl, secureStorage: storage);
      final res = await dio.get('/users/duplication', queryParameters: {
        'userName': userName,
        'phone': phoneNumber,
        'email': email,
      });
      if (res.statusCode == 200) {
        return res.data;
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  //
  // Store Subscription
  //

  Future<Map<String, dynamic>> favoriteStore(
      {required String storeID, required bool isFavorite}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      if (isFavorite) {
        final res = await dio
            .post('/stores/$storeID/subscription', data: {'storeUid': storeID});
        if (res.statusCode == 201) {
          return res.data;
        } else {
          throw Exception(res.statusMessage);
        }
      } else {
        final res = await dio.delete('/stores/$storeID/subscription',
            data: {'storeUid': storeID});
        if (res.statusCode == 200) {
          return res.data;
        } else {
          throw Exception(res.statusMessage);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  //
  // Store
  //

  Future<Map<String, dynamic>> getFavoriteStores(
      {int page = 0,
      int perPage = 10,
      String? storeName,
      String? storeCategoryUid,
      String? productName,
      double? latitude,
      double? longitude}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final res = await dio.get('/stores/subscribing', queryParameters: {
        'page': page,
        'perPage': perPage,
        'storeName': storeName,
        'storeCategoryUid': storeCategoryUid,
        'productName': productName,
        'latitude': latitude,
        'longitude': longitude,
      });
      if (res.statusCode == 200) {
        return res.data;
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStoreDeliveryFee(
      {required String storeID,
      required double longitude,
      required double latitude}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final res =
          await dio.get('/stores/$storeID/delivery-price', queryParameters: {
        'storeUid': storeID,
        'longitude': longitude,
        'latitude': latitude,
      });
      if (res.statusCode == 200) {
        return res.data;
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  //
  // Coupon
  //

  Future<Map<String, dynamic>> downloadCoupon({required String couponUid}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final res = await dio.get('/coupons/$couponUid');
      if (res.statusCode == 201) {
        return res.data;
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  //
  // Product Questions
  //

  // Future<void> postQuestion({required String productID, required String comment})


  //
  // Product Subscription
  //

  Future<Map<String, dynamic>> favoriteProduct({required String productID, required bool isFavorite}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      if (isFavorite) {
        final res = await dio
            .post('/products/$productID/subscription');
        if (res.statusCode == 201) {
          return res.data;
        } else {
          throw Exception(res.statusMessage);
        }
      } else {
        final res = await dio.delete('/products/$productID/subscription');
        if (res.statusCode == 200) {
          return res.data;
        } else {
          throw Exception(res.statusMessage);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

   //
  // Order
  //

  Future<List<Map<String, dynamic>>> getOrderSummaryList(
      {int page = 0,
      int perPage = 10,
      required BackendOrderStatus orderStatusFilter}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/orders',
        queryParameters: {
          'page': page,
          'perPage': perPage,
          'orderStatus': orderStatusFilter.index,
        },
      );
      if (response.statusCode == 200) {
        return response.data['rows'];
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getOrderDetail({required String uid}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get('/orders/$uid');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}