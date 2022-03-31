part of 'incle_api.dart';

class IncleClientAPI {
  final baseUrl = "http://backend.wim.kro.kr:5000/api/v1";
  final FlutterSecureStorage storage;

  IncleClientAPI(this.storage);

  //
  // Auth
  //

  Future<void> signin({required String id, required String password}) async {
    try {
      final dio = getClientDioClient(baseUrl: baseUrl, secureStorage: storage);
      final res = await dio
          .post('/login-user', data: {'userName': id, 'password': password});
      if (res.statusCode == 201) {
        storage.write(key: 'id', value: id);
        storage.write(key: 'password', value: password);
        storage.write(key: 'accessToken', value: res.data['accessToken']);
        storage.write(key: 'refreshToken', value: res.data['refreshToken']);
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signout() async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final res = await dio.post('/logout');
      if (res.statusCode == 201) {
        await storage.deleteAll();
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signup(
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
        return;
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editUserInfo({
    required String password,
    required String name,
    required String displayName,
    required String phoneNumber,
    required File profileImage,
  }) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
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
        return;
      } else {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> findID({required String phoneNumber}) async {
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

  Future<Map> findPassword({required String id, required String email}) async {
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

  Future<Map> getUserProfile() async {
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

  Future<List> checkDuplicate(
      {String? userName, String? phoneNumber, String? email}) async {
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

  Future<Map> favoriteStore(
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

  Future<Map> getFavoriteStores(
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

  Future<Map> getStoreDeliveryFee(
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

  Future<Map> downloadCoupon({required String couponUid}) async {
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

  Future<void> postQuestion(
      {required String productID, required String comment}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final res = await dio.post('/stores/products/questions',
          data: {'comment': comment, 'productUid': productID});
      if (res.statusCode != 201) {
        throw Exception(res.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  //
  // Product Subscription
  //

  Future<Map> favoriteProduct(
      {required String productID, required bool isFavorite}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      if (isFavorite) {
        final res = await dio.post('/products/$productID/subscription');
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

  Future<List> getOrderSummaryList(
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

  Future<Map> getOrderDetail({required String uid}) async {
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

  Future<void> requestCancel(
      {required String orderUid,
      required String reason,
      required String detailReason}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.post(
        '/orders/$orderUid/cancels',
        data: {
          'reason': reason,
          'remark': detailReason,
        },
      );
      if (response.statusCode == 201) {
        return;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestRefund(
      {required String orderUid,
      required String reason,
      required String detailReason,
      List<File>? images}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final formData = FormData.fromMap({
        'reason': reason,
        'remark': detailReason,
      });
      if (images != null) {
        for (var i = 0; i < images.length; i++) {
          formData.files.add(MapEntry(
              'refundFile',
              await MultipartFile.fromFile(images[i].path,
                  filename: images[i].path.split('/').last)));
        }
      }
      final response = await dio.post(
        '/orders/$orderUid/refunds',
        data: formData,
      );
      if (response.statusCode == 201) {
        return;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  //
  // Payment
  //

  Future<Map> generatePayment({
    required String merchanUid,
    required List orders,
    required int point,
    required bool isQuick,
    required String recipient,
    required String phone,
    required String address,
    required String addressDetail,
    required String deliveryRemart,
    required double longitude,
    required double latitude,
  }) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.post(
        '/payments',
        data: {
          'merchantUid': merchanUid,
          'orders': orders,
          'point': point,
          'isQuick': isQuick,
          'recipient': recipient,
          'phone': phone,
          'address': address,
          'addressDetail': addressDetail,
          'deliveryRemark': deliveryRemart,
          'longitude': longitude,
          'latitude': latitude,
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

  Future<Map> completePayment(
      {required String paymentServiceUid, required String merchantUid}) async {
    final dio = getClientDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/payments/complete',
        data: {
          'merchantUid': merchantUid,
          'impUid': paymentServiceUid,
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

  //
  // Review
  //

  Future<Map> postReview(
      {required String orderUid,
      required int rating,
      required int height,
      required int weight,
      required String comment,
      required String suitability,
      List<File>? images}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final formData = FormData.fromMap({
        'orderUid': orderUid,
        'rating': rating,
        'height': height,
        'weight': weight,
        'comment': comment,
        'suitability': suitability,
      });

      if (images != null) {
        for (var file in images) {
          formData.files.add(MapEntry(
              'reviewFile',
              await MultipartFile.fromFile(file.path,
                  filename: file.path.split('/').last)));
        }
      }
      final response = await dio.post(
        '/reviews',
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
}
