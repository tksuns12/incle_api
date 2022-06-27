part of 'incle_api.dart';

class IncleClientAPI {
  final baseUrl = "http://backend.wim.kro.kr:5000/api/v1";
  final FlutterSecureStorage storage;

  IncleClientAPI(this.storage);

  //
  // Auth
  //

  Future<bool> isSignedIn() async {
    try {
      return (await storage.read(key: 'accessToken')) != null &&
          (await storage.read(key: 'refreshToken')) != null;
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signin({required String id, required String password}) async {
    try {
      final dio = getClientDioClient(baseUrl: baseUrl, secureStorage: storage);
      final res = await dio
          .post('/login-user', data: {'userName': id, 'password': password});
      await storage.write(key: 'accessToken', value: res.data['accessToken']);
      await storage.write(key: 'refreshToken', value: res.data['refreshToken']);
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signout() async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      await dio.post('/logout');
      await storage.deleteAll();
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
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
      dio.options.contentType = 'multipart/form-data';
      final formData = FormData.fromMap({
        'userName': id,
        'password': password,
        'name': name,
        'displayName': nickname,
        'phone': phoneNumber,
        'gender': gender,
        'birth': DateFormat('yyyyMMdd').format(birth),
        'email': email,
      });
      formData.files.add(MapEntry(
          'userProfile',
          await MultipartFile.fromFile(profileImage.path,
              filename: profileImage.path.split('/').last,
              contentType: MediaType.parse('image/jpeg'))));
      await dio.post('/users', data: formData);
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editUserInfo({
    required String? password,
    required String? name,
    required String? displayName,
    required String? phoneNumber,
    required File? profileImage,
  }) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final formData = FormData.fromMap({
        'password': password ?? '',
        'name': name ?? '',
        'displayName': displayName ?? '',
        'phone': phoneNumber ?? '',
      });
      if (profileImage != null) {
        formData.files.add(MapEntry(
            'userProfile',
            await MultipartFile.fromFile(profileImage.path,
                filename: profileImage.path.split('/').last,
                contentType: MediaType.parse('image/jpeg'))));
      }
      await dio.patch('/users', data: formData);
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> findID(
      {required String phoneNumber,
      required String verificationCode,
      required String email,
      required String name}) async {
    try {
      final dio = getClientDioClient(baseUrl: baseUrl, secureStorage: storage);
      await dio.post('/users/username', data: {
        'phone': phoneNumber,
        'email': email,
        'name': name,
        'verifyNumber': verificationCode
      });
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String id,
    required String newPassword,
    required String name,
    required String phoneNumber,
    required String verificationCode,
  }) async {
    try {
      final dio = getClientDioClient(baseUrl: baseUrl, secureStorage: storage);
      await dio.post('/users/password', data: {
        'userName': id,
        'password': newPassword,
        'name': name,
        'phone': phoneNumber,
        'verifyNumber': verificationCode
      });
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> getUserProfile() async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final res = await dio.get('/users/profile');
      return res.data;
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List> checkDuplicate(
      {String? id,
      String? phoneNumber,
      String? email,
      String? nickname}) async {
    try {
      final dio = getClientDioClient(baseUrl: baseUrl, secureStorage: storage);
      final queryParameter = <String, dynamic>{};
      if (id != null) {
        queryParameter['userName'] = id;
      }
      if (phoneNumber != null) {
        queryParameter['phone'] = phoneNumber;
      }
      if (email != null) {
        queryParameter['email'] = email;
      }
      if (nickname != null) {
        queryParameter['displayName'] = nickname;
      }
      final res =
          await dio.get('/users/duplication', queryParameters: queryParameter);
      return res.data;
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendFCMToken(String token) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch(
        '',
        data: {
          'fcmToken': token,
        },
      );
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  //
  // Store Subscription
  //

  Future<void> favoriteStore(
      {required String storeID, required bool isFavorite}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      if (isFavorite) {
        await dio
            .post('/stores/$storeID/subscription', data: {'storeUid': storeID});
      } else {
        await dio.delete('/stores/$storeID/subscription',
            data: {'storeUid': storeID});
      }
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  //
  // Store
  //

  Future<List> getFavoriteStores(
      {int page = 0,
      int perPage = 10,
      String? storeCategoryUid,
      String? searchKeyword,
      double? latitude,
      double? longitude}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);

      final queryParameter = <String, dynamic>{
        'page': page,
        'perPage': perPage,
      };
      if (storeCategoryUid != null) {
        queryParameter['targetTagUid'] = storeCategoryUid;
      }
      if (latitude != null) {
        queryParameter['latitude'] = latitude;
      }
      if (longitude != null) {
        queryParameter['longitude'] = longitude;
      }
      if (searchKeyword != null) {
        queryParameter['q'] = searchKeyword;
      }

      final res =
          await dio.get('/stores/subscribing', queryParameters: queryParameter);
      return res.data['rows'];
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
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
          await dio.get('/stores/$storeID/delivery-fee', queryParameters: {
        'storeUid': storeID,
        'longitude': longitude,
        'latitude': latitude,
      });
      return res.data;
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List> getStoresByRanking(
      {required int page,
      required int perPage,
      String? storeCategoryUid}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final queryParameter = <String, dynamic>{
        'page': page,
        'perPage': perPage,
      };
      if (storeCategoryUid != null) {
        queryParameter['targetTagUid'] = storeCategoryUid;
      }
      final res =
          await dio.get('/stores/ranks', queryParameters: queryParameter);
      return res.data['rows'];
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> getStoreDetail(
      {required String storeUid, double? latitude, double? longitude}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final queryParameter = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude
      };
      final response = await dio.get(
        '/stores/$storeUid/detail',
        queryParameters: queryParameter,
      );
      return response.data;
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  //
  // Coupon
  //

  Future<void> downloadCoupon({required String couponUid}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      await dio.get('/coupons/$couponUid');
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List> getMyCoupons({required int page, required int perPage}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final queryParameter = <String, dynamic>{
        'page': page,
        'perPage': perPage,
      };
      final res =
          await dio.get('/coupons/downloads', queryParameters: queryParameter);
      return res.data['rows'];
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
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
      await dio.post('/stores/products/questions',
          data: {'comment': comment, 'productUid': productID});
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List> getProductQuestions(
      {int page = 0,
      int perPage = 10,
      String? productUid,
      String? storeUid,
      required bool? isReplied}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final queryParameter = <String, dynamic>{
        'page': page,
        'perPage': perPage
      };
      if (productUid != null) {
        queryParameter['productUid'] = productUid;
      }
      if (storeUid != null) {
        queryParameter['storeUid'] = storeUid;
      }
      if (isReplied != null) {
        queryParameter['isReplied'] = isReplied ? 1 : 0;
      }

      final response = await dio.get(
        '/stores/products/questions',
        queryParameters: queryParameter,
      );
      return response.data['rows'];
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List> getMyQuestions() async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final res = await dio.get('/stores/products/questions/me');
      return res.data['rows'];
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  //
  // Product Subscription
  //

  Future<void> favoriteProduct(
      {required String productID, required bool isFavorite}) async {
    try {
      final dio = getClientDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      if (isFavorite) {
        await dio.post('/stores/products/$productID/subscription');
      } else {
        await dio.delete('/stores/products/$productID/subscription');
      }
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  //
  // Product
  //

  Future<Map> getProductDetail({required String productID}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/stores/products/$productID',
      );
      return response.data;
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List> getRelatedProducts({required String productID}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get('/products/$productID/relates');

      return response.data['rows'];
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List> getFavoriteProducts(
      {required int page,
      required int perPage,
      String? productCategoryID,
      OrderValue? orderValue,
      OrderProperty? orderProperty}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final queryParameter = <String, dynamic>{
        'page': page,
        'perPage': perPage,
      };
      if (productCategoryID != null) {
        queryParameter['productCategoryUid'] = productCategoryID;
      }
      if (orderValue != null) {
        queryParameter['orderValue'] = orderValue;
      }
      if (orderProperty != null) {
        queryParameter['orderProperty'] = orderProperty;
      }
      final response = await dio.get('/stores/products/subscribing',
          queryParameters: queryParameter);
      return response.data['rows'];
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
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
      required List<OrderStatusEnum> orderStatuses,
      bool? isQuick}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final queryParameter = <String, dynamic>{
        'page': page,
        'perPage': perPage,
        'orderStatuses': orderStatuses.map((e) => e.number).toList(),
      };
      queryParameter['isQuick'] = (() {
        if (isQuick == null) {
          return 0;
        } else {
          return isQuick ? 1 : -1;
        }
      })();
      final response = await dio.get(
        '/orders',
        queryParameters: queryParameter,
      );
      return response.data['rows'];
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> getOrderDetail({required String uid}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get('/orders/$uid');
      return response.data;
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
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
      await dio.post(
        '/orders/$orderUid/cancels',
        data: {
          'reason': reason,
          'remark': detailReason,
        },
      );
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
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
                  filename: images[i].path.split('/').last,
                  contentType: MediaType.parse('image/jpeg'))));
        }
      }
      await dio.post(
        '/orders/$orderUid/refunds',
        data: formData,
      );
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> makeOrderDone({required String orderUid}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.post('/orders/$orderUid', data: {'orderStatus': 2});
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  //
  // Payment
  //

  Future<void> generatePayment({
    required String merchantUid,
    required List<StoreWiseOrderProducts> orders,
    required int point,
    required bool isQuick,
    required String recipient,
    required String phone,
    required String address,
    required String addressDetail,
    required String deliveryRemark,
    required double longitude,
    required double latitude,
  }) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    final data = FormData.fromMap({
      'merchantUid': merchantUid,
      'point': point,
      'isQuick': isQuick ? 1 : 0,
      'recipient': recipient,
      'phone': phone,
      'address': address,
      'addressDetail': addressDetail,
      'deliveryRemark': deliveryRemark,
      'longitude': longitude,
      'latitude': latitude,
    });

    for (final storewiseproducts in orders) {
      for (final product
          in storewiseproducts.productOptionGroupUidQuantity.entries) {
        data.fields.add(MapEntry(
            'orders',
            json.encode({
              'productOptionGroupUid': product.key,
              'count': product.value,
              'couponUid': storewiseproducts.couponUid
            })));
      }
    }

    try {
      await dio.post(
        '/payments',
        data: data,
      );
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
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
      return response.data;
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  //
  // Review
  //

  Future<void> postReview(
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
                  filename: file.path.split('/').last,
                  contentType: MediaType.parse('image/jpeg'))));
        }
      }
      await dio.post(
        '/reviews',
        data: formData,
      );
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  //
  // Notification
  //

  Future<List> getNotificationSummaries(
      {required int page, required int perPage}) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio
          .get('/alarms', queryParameters: {'page': page, 'perPage': perPage});
      return response.data['rows'];
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> getNotificationDetail(String notificationUid) async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get('/alarms/$notificationUid');
      return response.data;
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  //
  // Point
  //

  Future<Map> getPointRatio() async {
    final dio = getClientDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get('/points/accumulation-rate');
      return response.data;
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }
}
