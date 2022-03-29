part of 'incle_api.dart';

class IncleGeneralAPI {
  final baseUrl = "http://backend.wim.kro.kr:5000/api/v1";
  final FlutterSecureStorage storage;

  IncleGeneralAPI(this.storage);

  //
  // Health
  //

  Future<bool> isServerHealthy() async {
    try {
      final dio = getPartnersDioClient(
          baseUrl: 'http://backend.wim.kro.kr:5000/api/health',
          secureStorage: storage,
          needAuthorization: false);
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

  //
  // Auth
  //

  Future<Map> sendVerifyNum(String phoneNumber) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/phone',
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
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/phone/$phoneNumber',
        queryParameters: {
          'phone': phoneNumber,
          'verifyNumber': code,
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
  // Store
  //

  Future<List<Map<String, dynamic>>> getStoreList(
      {int page = 0,
      int perPage = 10,
      String? storeName,
      String? storeCategoryUid,
      String? productName,
      double? latitude,
      double? longitude}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get(
        '/stores',
        queryParameters: {
          'page': page,
          'perPage': perPage,
          'name': storeName,
          'targetTagUid': storeCategoryUid,
          'productName': productName,
          'latitude': latitude,
          'longitude': longitude,
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

  Future<List<Map<String, dynamic>>> getStoreCategories() async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get('/stores/tags');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getCouponList() async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/coupons',
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

  //
  // Category
  //

  Future<List<Map<String, dynamic>>> getProductParentCategories() async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/categories',
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

  Future<List<Map<String, dynamic>>> getSubCategories(
      String parentCategoryID) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/categories/$parentCategoryID',
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

  //
  // Banner
  //

  Future<List<Map<String, dynamic>>> getBanners() async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get(
        '/banners',
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

  //
  // Product Question
  //

  Future<List<Map<String, dynamic>>> getProductQuestions({int page = 0, int perPage = 10, String? productUid}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get(
        '/stores/product/questions',
        queryParameters: {
          'page': page,
          'perPage': perPage,
          'productUid': productUid,
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

  //
  // Product
  //

  Future<Map<String, dynamic>> getProductDetail(
      {required String productID}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get(
        '/products/$productID',
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

  Future<List<Map<String, dynamic>>> getProductList({
    OrderProperty orderProperty = OrderProperty.createdDate,
    OrderValue orderValue = OrderValue.DESC,
    String? findProperty,
    String? findValue,
    FindType? findType,
    int page = 0,
    int perPage = 10,
    String? storeUid,
    String? productParentCategoryUid,
    FilterType discoundFilter = FilterType.all,
    FilterType recommendedFilter = FilterType.all,
  }) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      Map<String, dynamic> _queryParameter = {
        'orderProperty': orderProperty.toString(),
        'orderValue': orderValue.toString(),
        'page': page,
        'perPage': perPage,
        'storeUid': storeUid,
        'productParentCategoryUid': productParentCategoryUid,
        'isDiscountedProduct': discoundFilter.value,
        'isRecommendedProduct': recommendedFilter.value,
      };
      final response =
          await dio.get('/products', queryParameters: _queryParameter);
      if (response.statusCode == 200) {
        return response.data;
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

  Future<Map<String, dynamic>> generatePayment({
    required String merchanUid,
    required List<Map<String, dynamic>> orders,
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
    final dio = getPartnersDioClient(
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

  Future<Map<String, dynamic>> completePayment(
      {required String paymentServiceUid, required String merchantUid}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
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

  Future<List<Map<String, dynamic>>> getReviewList(
      {int page = 0, int perPage = 10, String? productUid}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage);
    try {
      Map<String, dynamic> _queryParameter = {
        'page': page,
        'perPage': perPage,
        'productUid': productUid,
      };
      final response =
          await dio.get('/reviews', queryParameters: _queryParameter);
      if (response.statusCode == 200) {
        return response.data['rows'];
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getDetailReview(String reviewID) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get(
        '/reviews/$reviewID',
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
