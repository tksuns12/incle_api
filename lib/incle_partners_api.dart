part of 'incle_api.dart';

class InclePartnersAPI {
  final baseUrl = "http://incle-staging.kro.kr:5000/api/v1";
  final FlutterSecureStorage storage;

  InclePartnersAPI(this.storage);

  //
  // Auth
  //

  Future<bool> isSignedIn() async {
    try {
      return (await storage.read(key: 'accessToken')) != null &&
          (await storage.read(key: 'refreshToken')) != null;
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signout() async {
    try {
      final dio = getPartnersDioClient(
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

  Future<void> login(String id, String password) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/login-partners',
        data: {
          'partnersName': id,
          'password': password,
        },
      );
      await storage.write(
          key: 'accessToken', value: response.data['accessToken']);
      await storage.write(
          key: 'refreshToken', value: response.data['refreshToken']);
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
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch(
        '',
        data: {
          'fcmToken': token,
        },
      );
      return;
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser() async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.delete('/partners');
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

  //
  // Partners
  //

  Future<void> signup({
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
    String? storeAddress1,
    String? storeAddress2,
    String? storePhone,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
    List<List<bool>>? dayoffs,
    String? storeDescription,
    List<File>? storePictures,
    String? storeName,
    bool? isRestHolidy,
    double? latitude,
    double? longitude,
    String? postCode,
    int? freeDeliveryCondition,
    String? targetTagUid,
    File? storeProfile,
  }) async {
    try {
      final dio =
          getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
      final createStoreRestsDto = (() {
        final dto = <Map<String, int>>[];
        for (var i = 0; i < dayoffs!.length; i++) {
          for (var j = 0; j < dayoffs[i].length; j++) {
            if (dayoffs[i][j]) {
              dto.add({
                'week': i + 1,
                'day': j + 1,
              });
            }
          }
        }
        return dto;
      })();
      final formData = FormData.fromMap({
        'partnersName': id,
        'password': password,
        'name': name,
        'phone': phoneNumber,
        'email': email,
        'accountBank': bank,
        'accountNumber': accountNumber,
        'accountName': accountOwner,
        'storeName': storeName,
        'ownerName': ownerName,
        'storePhone': storePhone,
        'location': storeAddress1,
        'locationDetail': storeAddress2,
        'longitude': longitude,
        'latitude': latitude,
        'businessNumber': businessNumber,
        'description': storeDescription,
        'freeDelivery': freeDeliveryCondition,
        'targetTagUid': targetTagUid,
        'startDate':
            '${openTime!.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}',
        'endDate':
            '${closeTime!.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}',
        'isRestHoliday': isRestHolidy ?? false ? 1 : 0
      });

      for (var restItem in createStoreRestsDto) {
        formData.fields
            .add(MapEntry('createStoreRestsDto', jsonEncode(restItem)));
      }

      for (var picture in storePictures!) {
        formData.files.add(MapEntry(
            'storeProfile',
            await MultipartFile.fromFile(picture.path,
                filename: picture.path.split('/').last,
                contentType: MediaType.parse('image/jpeg'))));
      }
      formData.files.add(MapEntry(
          'businessRegistrationFile',
          await MultipartFile.fromFile(registration!.path,
              filename: registration.path.split('/').last,
              contentType: MediaType.parse('image/jpeg'))));
      formData.files.add(MapEntry(
          'businessReportFile',
          await MultipartFile.fromFile(registration2!.path,
              filename: registration2.path.split('/').last,
              contentType: MediaType.parse('image/jpeg'))));
      dio.options.contentType = 'multipart/form-data';

      await dio.post(
        '/partners',
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

  Future<void> updateUserInfo(
      {required String? password,
      required String? name,
      required String? phoneNumber,
      required String? email,
      required File? profileImage}) async {
    try {
      final dio = getPartnersDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
      final formDataMap = <String, dynamic>{};
      if (password != null) {
        formDataMap['password'] = password;
      }
      if (name != null) {
        formDataMap['name'] = name;
      }
      if (phoneNumber != null) {
        formDataMap['phone'] = phoneNumber;
      }
      if (email != null) {
        formDataMap['email'] = email;
      }
      final formData = FormData.fromMap(formDataMap);

      if (profileImage != null) {
        formData.files.add(MapEntry(
            'partnersProfile',
            await MultipartFile.fromFile(profileImage.path,
                filename: profileImage.path.split('/').last,
                contentType: MediaType.parse('image/jpeg'))));
      }
      dio.options.contentType = 'multipart/form-data';
      await dio.patch(
        '/partners/profile',
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

  Future<void> updateBankAccountInfo(
      {required String bankName,
      required String accountNumber,
      required String accountOwnerName}) async {
    try {
      final dio = getPartnersDioClient(
          baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);

      await dio.patch(
        '/partners/account',
        data: {
          'accountBank': bankName,
          'accountNumber': accountNumber,
          'accountName': accountOwnerName,
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

  Future<Map> getPartnersProfile() async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/partners/profile',
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

  Future<void> resetPassword(
      {required String phone,
      required String phoneVerificationCode,
      required String id,
      required String password,
      required String name}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      await dio.post(
        '/partners/password',
        data: {
          'phone': phone,
          'verifyNumber': phoneVerificationCode,
          'partnersName': id,
          'password': password,
          'name': name
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

  Future<void> findId(
      {required String phone, required String verificationCode}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      await dio.post(
        '/partners/partnersname',
        data: {
          'phone': phone,
          'verifyNumber': verificationCode,
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

  /// name 패러미터에는 email, id, phone, partnersNames 넷 중 하나만 입력해야 합니다.
  Future<List> duplicateCheck(
      {String? userName,
      String? phoneNumber,
      String? email,
      String? name}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final queryParameters = <String, String>{};
      if (userName != null) {
        queryParameters['partnersName'] = userName;
      }
      if (name != null) {
        queryParameters['name'] = name;
      }
      if (phoneNumber != null) {
        queryParameters['phone'] = phoneNumber;
      }
      if (email != null) {
        queryParameters['email'] = email;
      }
      final response = await dio.get(
        '/partners/duplication',
        queryParameters: queryParameters,
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

  Future<void> createCoupon(
      {required String name,
      required int price,
      required int condition,
      DateTime? limitDate}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final data = {
        'name': name,
        'amount': price,
        'condition': condition,
      };
      if (limitDate != null) {
        data['limitDate'] = limitDate.millisecondsSinceEpoch;
      }
      await dio.post('/coupons', data: data);
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCoupon(String couponID) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.delete(
        '/coupons/$couponID',
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

  //
  // Delivery
  //

  Future<List> getDeliver(String storeUid) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/stores/$storeUid/deliveries',
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

  Future<void> addDeliver({required int distance, required int price}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.post(
        '/stores/deliveries',
        data: {
          'km': distance,
          'price': price,
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

  Future<void> updateDeliver(
      {required int distance, required int price}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch(
        '/stores/deliveries',
        data: {
          'km': distance,
          'price': price,
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

  Future<void> deleteDeliver(int distance) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.delete(
        '/stores/deliveries/',
        data: {'km': distance},
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

  Future<void> updateFreeDeliveryCondition(int condition) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch(
        '/stores/free-deliveries',
        data: {'freeDelivery': condition},
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
  // Store
  //

  Future<void> unpausePartners(
      {required TimeOfDay startTime, required TimeOfDay endTime}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch('/stores/pause', data: {
        'pause': 0,
        'pauseStartDate':
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        'pauseEndDate':
            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
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

  Future<void> pausePartners(TimeOfDay startTime, TimeOfDay endTime) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch(
        '/stores/pause',
        data: {
          'pauseStartDate':
              '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
          'pauseEndDate':
              '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
          'pause': 1,
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

  Future<Map> getStoreDetail(
      {required String storeUid, double? latitude, double? longitude}) async {
    final dio = getPartnersDioClient(
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
  // Product Questions
  //

  Future<void> replyQuestion(
      {required String questionUid, required String reply}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch(
        '/stores/products/questions/$questionUid',
        data: {
          'reply': reply,
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

  Future<List> getProductQuestions(
      {int page = 0,
      int perPage = 10,
      String? productUid,
      String? storeUid,
      required bool? isReplied}) async {
    final dio = getPartnersDioClient(
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
        queryParameter['isReplied'] = isReplied ? 1 : -1;
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

  //
  // Product
  //

    Future<List> getRelatedProducts(String productUid) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/stores/products/$productUid/relates',
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
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage,needAuthorization: true);
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

  Future<void> uploadProduct(
      {required String name,
      required String price,
      required bool todayGet,
      required List<File> images,
      required int modelHeight,
      required int modelWeight,
      required String modelNormalSize,
      required String modelSize,
      required Map<List<String>, int> optionStocks,
      required List<String> cody,
      required List<Tuple2<String, List<File>>> description,
      required String subCategoryUid}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final formData = FormData.fromMap({
        'productCategoryDetailUid': subCategoryUid,
        'name': name,
        'modelHeight': modelHeight,
        'modelWeight': modelWeight,
        'modelNormalSize': modelNormalSize,
        'modelSize': modelSize,
        'price': price,
        'todayGet': todayGet ? 1 : 0,
      });

      if (cody.isNotEmpty) {
        if (cody.length == 1) {
          formData.fields.add(
              MapEntry('codyProductsUid[]', jsonEncode(int.parse(cody.first))));
        } else {
          for (var codyID in cody) {
            formData.fields.add(MapEntry('codyProductsUid[]', codyID));
          }
        }
      }

      for (var optionStock in optionStocks.entries) {
        // optionStock은 예를 들어 {['컬러/블랙', '사이즈/XL']: 10} 이런 식이다.
        final parsedOptionStock = {};
        // parsedOptionStock은 {opt1Name:컬러, opt2:블랙, opt2Name: 사이즈, opt2:XL, stock: 10} 이런 식이다.
        for (var i = 0; i < 10; i++) {
          // 무조건 10까지 반복문을 돌린다.
          if (i < optionStock.key.length) {
            // 만약 아직 남아 있는 옵션이 있다면 옵션을 추가한다.
            final optionNames = optionStock.key[i].split('/');
            parsedOptionStock['opt${i + 1}Name'] = optionNames[0];
            parsedOptionStock['opt${i + 1}'] = optionNames[1];
          } else {
            // 남아 있는 옵션이 없다면 10까지 돌리면서 null을 대입한다.
            parsedOptionStock['opt${i + 1}Name'] = null;
            parsedOptionStock['opt${i + 1}'] = null;
          }
          parsedOptionStock['stock'] = optionStock.value;
        }
        formData.fields.add(
            MapEntry('createProductOptions', jsonEncode(parsedOptionStock)));
      }

      for (var descItem in description) {
        formData.fields.add(MapEntry(
            'createProductDescriptionDto',
            jsonEncode({
              'description': descItem.item1,
              'originalNames':
                  descItem.item2.map((e) => e.path.split('/').last).toList()
            })));
      }
      for (var image in images) {
        formData.files.add(
          MapEntry(
            'productFile',
            await MultipartFile.fromFile(image.path,
                filename: image.path.split('/').last,
                contentType: MediaType.parse('image/jpeg')),
          ),
        );
      }
      for (var descItem in description) {
        for (var image in descItem.item2) {
          formData.files.add(
            MapEntry(
              'descriptionFile',
              await MultipartFile.fromFile(image.path,
                  filename: image.path.split('/').last,
                  contentType: MediaType.parse('image/jpeg')),
            ),
          );
        }
      }
      await dio.post('/stores/products', data: formData);
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(
      {required String uid,
      required String name,
      required String price,
      required bool todayGet,
      required List<File> images,
      required int modelHeight,
      required int modelWeight,
      required String modelNormalSize,
      required String modelSize,
      required Map<List<String>, int> optionStocks,
      required List<String> cody,
      required List<Tuple2<String, List<File>>> description,
      required String subCategoryUid}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);

    try {
      final formData = FormData.fromMap({
        'productCategoryDetailUid': subCategoryUid,
        'name': name,
        'modelHeight': modelHeight,
        'modelWeight': modelWeight,
        'modelNormalSize': modelNormalSize,
        'modelSize': modelSize,
        'price': price,
        'todayGet': todayGet ? 1 : 0,
      });

      if (cody.isNotEmpty) {
        if (cody.length == 1) {
          formData.fields.add(
              MapEntry('codyProductsUid[]', jsonEncode(int.parse(cody.first))));
        } else {
          for (var codyID in cody) {
            formData.fields.add(MapEntry('codyProductsUid[]', codyID));
          }
        }
      } else {
        formData.fields.add(const MapEntry('codyProductsUid[]', '0'));
      }

      final productOptionStocks = (() {
        final result = <Map<String, dynamic>>[];
        for (var optionStock in optionStocks.entries) {
          // optionStock은 예를 들어 {['컬러/블랙', '사이즈/XL']: 10} 이런 식이다.
          final parsedOptionStock = <String, dynamic>{};
          // parsedOptionStock은 {opt1Name:컬러, opt2:블랙, opt2Name: 사이즈, opt2:XL, stock: 10} 이런 식이다.
          for (var i = 0; i < 10; i++) {
            // 무조건 10까지 반복문을 돌린다.
            if (i < optionStock.key.length) {
              // 만약 아직 남아 있는 옵션이 있다면 옵션을 추가한다.
              final optionNames = optionStock.key[i].split('/');
              parsedOptionStock['opt${i + 1}Name'] = optionNames[0];
              parsedOptionStock['opt${i + 1}'] = optionNames[1];
            } else {
              // 남아 있는 옵션이 없다면 10까지 돌리면서 null을 대입한다.
              parsedOptionStock['opt${i + 1}Name'] = null;
              parsedOptionStock['opt${i + 1}'] = null;
            }
            parsedOptionStock['stock'] = optionStock.value;
          }
          result.add(parsedOptionStock);
        }
        return result;
      }());

      for (var optionStock in productOptionStocks) {
        formData.fields
            .add(MapEntry('createProductOptions', jsonEncode(optionStock)));
      }
      for (var descItem in description) {
        formData.fields.add(MapEntry(
            'createProductDescriptionDto',
            jsonEncode({
              'description': descItem.item1,
              'originalNames':
                  descItem.item2.map((e) => e.path.split('/').last).toList()
            })));
      }
      for (var image in images) {
        formData.files.add(
          MapEntry(
            'productFile',
            await MultipartFile.fromFile(image.path,
                filename: image.path.split('/').last,
                contentType: MediaType.parse('image/jpeg')),
          ),
        );
      }
      for (var descItem in description) {
        for (var image in descItem.item2) {
          formData.files.add(
            MapEntry(
              'descriptionFile',
              await MultipartFile.fromFile(image.path,
                  filename: image.path.split('/').last,
                  contentType: MediaType.parse('image/jpeg')),
            ),
          );
        }
      }

      await dio.patch('/stores/products/$uid/detail', data: formData);
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct({required String uid}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.delete('/stores/products/$uid');
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> soldoutProduct(
      {required String uid, required bool isSoldOut}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch(
        '/stores/products/$uid/soldout',
        data: {
          'isSoldOut': isSoldOut ? 1 : 0,
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

  Future<void> addProductOwnersRecommend(
      {required String uid, required bool isRecommended}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch(
        '/stores/products/$uid/recommendation',
        data: {'ownersRecommended': isRecommended ? 1 : 0},
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

  Future<void> addProductDiscount(
      {required String uid,
      int? discountedPrice,
      required bool isDiscounted}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch('/stores/products/$uid/discount',
          data: {'discountedPrice': isDiscounted ? discountedPrice : null});
    } on DioError catch (e) {
      throw Exception(
          'Error Type: ${e.type} | Status Code: ${e.response?.statusCode ?? 'No Code'} | Message: ${e.message}');
    } on PlatformException catch (e) {
      throw Exception('${e.code}: ${e.message} //// Detail: ${e.details}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> getProductDetail({required String productID}) async {
    final dio = getPartnersDioClient(
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

  //
  // Order
  //

  Future<List> getOrderSummaryList(
      {int page = 0,
      int perPage = 10,
      required List<OrderStatusEnum> orderStatuses,
      bool? isQuick}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/orders',
        queryParameters: {
          'page': page,
          'perPage': perPage,
          'orderStatus': orderStatuses.map((e) => e.number).toList(),
          'isQuick': (() {
            if (isQuick == null) {
              return 0;
            } else {
              return isQuick ? 1 : -1;
            }
          })()
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

  Future<Map> getOrderDetail({required String uid}) async {
    final dio = getPartnersDioClient(
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

  Future<void> processCancelRequest(
      {required String orderUid, required bool isApproved}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch(
        '/orders/$orderUid/cancels',
        data: {'isCancel': isApproved ? 1 : 0},
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

  Future<void> processRefundRequest(
      {required String orderUid,
      required OrderStatusEnum orderStatus,
      String? rejectReason}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final isRefund = (() {
        if (orderStatus == OrderStatusEnum.returned) {
          return 1;
        } else if (orderStatus == OrderStatusEnum.returning) {
          return 2;
        } else if (orderStatus == OrderStatusEnum.returnRejected) {
          return 0;
        } else {
          throw Exception('잘못된 주문 상태입니다.');
        }
      })();
      final data = <String, dynamic>{'isRefund': isRefund};
      if (rejectReason != null) {
        data['refundRejectReason'] = rejectReason;
      }
      await dio.patch(
        '/orders/$orderUid/refunds',
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

  Future<void> processOrderDeliveryState(
      {required String orderUid, required DeliveryStatus status}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.patch('/orders/$orderUid', data: {
        'orderStatus': (() {
          switch (status) {
            case DeliveryStatus.delivered:
              return 2;
            case DeliveryStatus.beingDelivered:
              return 1;
            case DeliveryStatus.pickedUp:
              return 4;
            default:
              return 3;
          }
        })()
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

  //
  // Review
  //

  Future<void> replyReview(
      {required String reviewUid, required String reply}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      await dio.post('/reviews/$reviewUid', data: {'reply': reply});
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

  Future<List> getOrderHistories(
      {required int page,
      required int perPage,
      String? merchantUid,
      List<OrderStatusEnum>? orderStatus}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final queryParameters = {
        'page': page,
        'perPage': perPage,
        'merchantUid': merchantUid,
      };
      if (orderStatus != null) {
        queryParameters['orderStatus'] =
            orderStatus.map((e) => e.number).toList();
      }
      final response = await dio.get(
        '/payments',
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

  Future<Map> getOrderHistoryDetail(String paymentID) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get('/payments/$paymentID');
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
  // Notification
  //

  Future<List> getNotificationSummaries(
      {required int page, required int perPage}) async {
    final dio = getPartnersDioClient(
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
    final dio = getPartnersDioClient(
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
    final dio = getPartnersDioClient(
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
