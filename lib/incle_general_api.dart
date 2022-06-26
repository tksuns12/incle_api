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
      await dio.get('/health');
      return true;
    } catch (e) {
      return false;
    }
  }

  //
  // Auth
  //

  Future<void> sendVerifyNum(String phoneNumber) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      await dio.post(
        '/phone',
        queryParameters: {
          'phone': phoneNumber,
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

  Future<String> checkVerifyNum(String phoneNumber, String code) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/phone/$phoneNumber',
        queryParameters: {
          'verifyNumber': code,
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
  // Store
  //

  Future<List> getStoreList(
      {int page = 0,
      int perPage = 10,
      String? storeCategoryUid,
      String? productName,
      double? latitude,
      double? longitude,
      String? searchKeyword}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final queryParameter = <String, dynamic>{
        'page': page,
        'perPage': perPage
      };
      if (storeCategoryUid != null) {
        queryParameter['targetTagUid'] = storeCategoryUid;
      }
      if (productName != null) {
        queryParameter['productName'] = productName;
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

      final response = await dio.get(
        '/stores',
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

  Future<List> getStoreCategories() async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get('/stores/tags');
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

  Future<List> getCouponList(String storeUid) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/coupons',
        queryParameters: {'storeUid': storeUid, 'page': 0, 'perPage': 1000},
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

  Future<List> getStoreByRanking(
      {required int page,
      required int pageSize,
      String? storeCategoryUid}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final queryParameter = <String, dynamic>{
        'page': page,
        'perPage': pageSize,
      };
      if (storeCategoryUid != null) {
        queryParameter['storeCategoryUid'] = storeCategoryUid;
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

  Future<Map> getDiscountQuantityLimit() async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final res = await dio.get('/stores/discounts');
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

  //
  // Category
  //

  Future<List> getProductParentCategories() async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/categories',
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

  Future<List> getSubCategories(String parentCategoryID) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/categories/$parentCategoryID',
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

  //
  // Banner
  //

  Future<List> getBanners() async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get(
        '/banners',
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

  //
  // Product
  //

  Future<List> getProductList({
    OrderProperty orderProperty = OrderProperty.createDate,
    OrderValue orderValue = OrderValue.DESC,
    String? findProperty,
    String? findValue,
    FindType? findType,
    int page = 0,
    int perPage = 10,
    String? searchKeyword,
    String? storeUid,
    String? productParentCategoryUid,
    FilterType discoundFilter = FilterType.all,
    FilterType recommendedFilter = FilterType.all,
  }) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      var queryParameter = <String, dynamic>{
        'orderProperty': orderProperty.name,
        'orderValue': orderValue.name,
        'page': page,
        'perPage': perPage,
        'isDiscountedProduct': discoundFilter.number,
        'isRecommendedProduct': recommendedFilter.number,
      };
      if (findProperty != null) {
        queryParameter['findProperty'] = findProperty;
      }
      if (findValue != null) {
        queryParameter['findValue'] = findValue;
      }
      if (findType != null) {
        queryParameter['findType'] = findType.name;
      }
      if (storeUid != null) {
        queryParameter['storeUid'] = storeUid;
      }
      if (productParentCategoryUid != null) {
        queryParameter['productCategoryUid'] = productParentCategoryUid;
      }
      if (searchKeyword != null) {
        queryParameter['q'] = searchKeyword;
      }

      final response =
          await dio.get('/stores/products', queryParameters: queryParameter);
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

  Future<List> getProductsByRanking(
      {required int page,
      required int perPage,
      String? productCategoryID,
      String? storeCateogryID}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'perPage': perPage,
      };
      if (productCategoryID != null) {
        queryParameters['productCategoryUid'] = productCategoryID;
      }
      if (storeCateogryID != null) {
        queryParameters['targetTagUid'] = storeCateogryID;
      }

      final response = await dio.get(
        '/stores/products/ranks',
        queryParameters: queryParameters,
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

  Future<List> getRelatedProducts(String productUid) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/products/$productUid/relates',
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

  //
  // Review
  //

  Future<List> getReviewList(
      {int page = 0,
      int perPage = 10,
      String? productUid,
      String? storeUid,
      bool? isReplied}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      var queryParameter = <String, dynamic>{
        'page': page,
        'perPage': perPage,
        'isReplied': isReplied == null
            ? 0
            : isReplied
                ? 1
                : -1
      };
      if (productUid != null) {
        queryParameter['productUid'] = productUid;
      }
      if (storeUid != null) {
        queryParameter['storeUid'] = storeUid;
      }

      final response =
          await dio.get('/reviews', queryParameters: queryParameter);
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

  Future<Map> getDetailReview(String reviewID) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get(
        '/reviews/$reviewID',
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
  // Notice
  //

  Future<List> getNotices(
      {required int page,
      required int perPage,
      required NoticeTarget noticeTarget}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get(
        '/notices',
        queryParameters: {
          'page': page,
          'perPage': perPage,
          'target': noticeTarget.name,
        },
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

  Future<Map> getNoticeDetail(String noticeID) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get('/notices/$noticeID');
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
  // FAQ
  //

  Future<List> getFAQSummaries(
      {required int page, required int perPage}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get(
        '/faqs',
        queryParameters: {
          'page': page,
          'perPage': perPage,
        },
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

  Future<List> getFAQSummariesByCategories() async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get('/faqs/categories');
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

  Future<Map> getFAQDetail(String faqID) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get('/faqs/$faqID');
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
  // Event
  //

  Future<List> getEventSummaries(
      {required int page, required int perPage}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get(
        '/events',
        queryParameters: {
          'page': page,
          'perPage': perPage,
        },
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

  Future<Map> getEventDetail(String eventID) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.get('/events/$eventID');
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
