part of 'incle_api.dart';

class InclePartnersAPI {
  final baseUrl = "http://backend.wim.kro.kr:5000/api/v1";
  final FlutterSecureStorage storage;

  InclePartnersAPI(this.storage);

  //
  // Auth
  //

  Future<bool> isSignedIn() async {
    return (await storage.read(key: 'id')) != null &&
        (await storage.read(key: 'password')) != null;
  }

  Future<void> signout() async {
    await storage.deleteAll();
  }

  Future<bool> isApproved() async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    final id = await storage.read(key: 'id');
    final password = await storage.read(key: 'password');
    final response = await dio.post(
      '/login-partners',
      data: {
        'id': id,
        'password': password,
      },
    );
    return response.statusMessage != '허가되지 않은 파트너스';
  }

  Future<Map> login(String id, String password) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final response = await dio.post(
        '/login-partners',
        data: {
          'partnersName': id,
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

  //
  // Partners
  //

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
    DateTime? openTime,
    DateTime? closeTime,
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
        'createStoreRestsDto': createStoreRestsDto,
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
        'startDate': openTime,
        'endDate': closeTime,
      });
      for (var picture in storePictures!) {
        formData.files.add(MapEntry(
            'storeProfile',
            await MultipartFile.fromFile(picture.path,
                filename: picture.path.split('/').last)));
      }
      formData.files.add(MapEntry(
          'businessRegistrationFile',
          await MultipartFile.fromFile(registration!.path,
              filename: registration.path.split('/').last)));
      formData.files.add(MapEntry(
          'businessReportFile',
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

  // updateProfile({
  //   String? id,
  //   String? password,
  //   String? name,
  //   String? phoneNumber,
  //   String? email,
  //   String? ownerName,
  //   String? businessNumber,
  //   dynamic registration,
  //   dynamic registration2,
  //   String? bank,
  //   String? accountNumber,
  //   String? accountOwner,
  //   String? storeCategories,
  //   String? storeAddress1,
  //   String? storeAddress2,
  //   String? storePhone,
  //   String? openTime,
  //   String? closeTime,
  //   List<List<bool>>? dayoffs,
  //   String? storeDescription,
  //   List? storePictures,
  //   String? storeName,
  //   bool? isRestHolidy,
  //   double? latitude,
  //   double? longitude,
  //   String? postCode,
  //   dynamic profilePicture,
  // }) async {
  //   try {
  //     final dio = getDioClient(
  //         baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);

  //     final formData = FormData.fromMap({
  //       'isRestHoliday': isRestHolidy,
  //       'id': id,
  //       'password': password,
  //       'ownerPhone': phoneNumber,
  //       'email': email,
  //       'ownerName': ownerName,
  //       'businessNumber': businessNumber,
  //       'accountBank': bank,
  //       'accountNumber': accountNumber,
  //       'accountName': accountOwner,
  //       'targetGender': storeCategories,
  //       'location': storeAddress1,
  //       'locationDetail': storeAddress2,
  //       'postNumber': postCode,
  //       'phone': storePhone,
  //       'startDate': openTime,
  //       'endDate': closeTime,
  //       'closedDays': '"closedDays":${jsonEncode(dayoffs)}',
  //       'name': storeName,
  //       'latitude': latitude,
  //       'longitude': longitude,
  //     });

  //     if (registration is File) {
  //       formData.files.add(MapEntry(
  //           'businessReport',
  //           await MultipartFile.fromFile(registration.path,
  //               filename: registration.path.split('/').last)));
  //     }
  //     if (registration2 is File) {
  //       formData.files.add(MapEntry(
  //           'businessRegistration',
  //           await MultipartFile.fromFile(registration2.path,
  //               filename: registration2.path.split('/').last)));
  //     }

  //     if (profilePicture is File) {
  //       formData.files.add(MapEntry(
  //           'profile',
  //           await MultipartFile.fromFile(profilePicture.path,
  //               filename: profilePicture.path.split('/').last)));
  //     }

  //     for (final picture in storePictures!) {
  //       if (picture is File) {
  //         formData.files.add(MapEntry(
  //             'storeImages',
  //             MultipartFile.fromFileSync(picture.path,
  //                 filename: picture.path.split('/').last)));
  //       } else {
  //         final res = await http.Client().get(picture);
  //         final direc = await getTemporaryDirectory();
  //         final path =
  //             direc.path + '/storeImage${storePictures.indexOf(picture)}.jpg';
  //         await File(path).writeAsBytes(res.bodyBytes);

  //         return MapEntry('storeImages',
  //             MultipartFile.fromFileSync(path, filename: path.split('/').last));
  //       }
  //     }
  //     final response = await dio.put(
  //       '',
  //       data: formData,
  //     );
  //     if (response.statusCode == 201) {
  //       return response.data;
  //     } else {
  //       throw Exception(response.statusMessage);
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<Map> getPartnersProfile() async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/partners/profile',
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

  // Future<Map> deleteAccount() async {
  //   final dio = getDioClient(
  //       baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
  //   try {
  //     final response = await dio.delete(
  //       '',
  //     );
  //     if (response.statusCode == 200) {
  //       storage.delete(key: 'token');
  //       storage.delete(key: 'id');
  //       storage.delete(key: 'password');
  //       return response.data;
  //     } else {
  //       throw Exception(response.statusMessage);
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<Map> findPasswordAllow(
  //     {required String email,
  //     required String phone,
  //     required String name}) async {
  //   final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
  //   try {
  //     final response = await dio.post(
  //       '/find/password/allow',
  //       data: {
  //         'email': email,
  //         'phone': phone,
  //         'name': name,
  //       },
  //     );
  //     if (response.statusCode == 201) {
  //       return response.data;
  //     } else {
  //       throw Exception(response.statusMessage);
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<Map> findPassword(String code, String password) async {
  //   final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
  //   try {
  //     final response = await dio.post(
  //       '/find/password',
  //       data: {
  //         'code': code,
  //         'password': password,
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       return response.data;
  //     } else {
  //       throw Exception(response.statusMessage);
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<Map> findId(String email, String name, String phone) async {
  //   final dio = getDioClient(baseUrl: baseUrl, secureStorage: storage);
  //   try {
  //     final response = await dio.post(
  //       '/find/id',
  //       data: {
  //         'email': email,
  //         'name': name,
  //         'phone': phone,
  //       },
  //     );
  //     if (response.statusCode == 201) {
  //       return response.data;
  //     } else {
  //       throw Exception(response.statusMessage);
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  /// name 패러미터에는 email, id, phone, partnersNames 넷 중 하나만 입력해야 합니다.
  Future<List> duplicateCheck(
      {String? userName, String? phoneNumber, String? email}) async {
    final dio = getPartnersDioClient(baseUrl: baseUrl, secureStorage: storage);
    try {
      final queryParameters = <String, String>{};
      if (userName != null) {
        queryParameters['name'] = userName;
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
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //
  // Coupon
  //

  Future<Map> createCoupon(
      {required String name,
      required int price,
      required int condition,
      DateTime? limitDate}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.post(
        '/coupons',
        data: {
          'name': name,
          'amount': price,
          'condition': condition,
          'limitDate': limitDate?.toIso8601String(),
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

  Future<Map> deleteCoupon(String couponID) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.delete(
        '/coupons/$couponID',
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

  //
  // Delivery
  //

  Future<List<Map>> getDeliver(String storeUid) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.get(
        '/stores/$storeUid/deliveries',
      );
      if (response.statusCode == 201) {
        return response.data['rows'];
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> addDeliver({required int distance, required int price}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.post(
        '/stores/deliveries',
        data: {
          'distance': distance,
          'price': price,
        },
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

  Future<Map> updateDeliver({required int distance, required int price}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.patch(
        '/stores/deliveries',
        data: {
          'km': distance,
          'price': price,
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

  Future<Map> deleteDeliver(int distance) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.delete(
        '/stores/deliveries/',
        data: {'km': distance},
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

  //
  // Store
  //

  Future<Map> unpausePartners() async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.delete(
        '/store/pause',
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
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.post(
        '/stores/pause',
        data: {
          'pauseStartDate':
              '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
          'pauseEndDate':
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

  //
  // Product Questions
  //

  Future<void> replyQuestion({required String questionUid, required String reply}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.post(
        '/store/products/questions/$questionUid',
        data: {
          'reply': reply,
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

  //
  // Product
  //

  Future<Map<String, dynamic>> uploadProduct(
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
      final productOptionStocks = (() {
        final result = [];
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
          result.add(parsedOptionStock);
        }
        return result;
      })();

      final formData = FormData.fromMap({
        'createProductOptions': productOptionStocks,
        'productCategoryDetailUid': subCategoryUid,
        'codyProductsUid': cody,
        'name': name,
        'description': description
            .map((e) => {
                  'description': e.item1,
                  'originalNames':
                      e.item2.map((e) => e.path.split('/').last).toList()
                })
            .toList(),
        'modelHeight': modelHeight,
        'modelWeight': modelWeight,
        'modelNormalSize': modelNormalSize,
        'modelSize': modelSize,
        'price': price,
        'todayGet': todayGet ? 1 : 0,
      });
      for (var image in images) {
        formData.files.add(
          MapEntry(
            'productProfile',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }
      for (var descItem in description) {
        for (var image in descItem.item2) {
          formData.files.add(
            MapEntry(
              'descriptionFile',
              await MultipartFile.fromFile(
                image.path,
                filename: image.path.split('/').last,
              ),
            ),
          );
        }
      }
      final response = await dio.post('/products', data: formData);
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  @experimental
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
    final dio = getPartnersDioClient(
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
      final response = await dio.put('/products/$uid', data: formData);
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteProduct({required String uid}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.delete('/products/$uid');
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> soldoutProduct(
      {required String uid, required bool isSoldOut}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.put(
        '/products/$uid/soldout',
        data: {
          'isSoldOut': isSoldOut ? 1 : 0,
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

  Future<Map> addProductOwnersRecommend(
      {required String uid, required bool isRecommended}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.put(
        '/products/$uid/recommendation',
        data: {'ownersRecommended': isRecommended ? 1 : 0},
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

  Future<Map> addProductDiscount(
      {required String uid,
      int? discountedPrice,
      required bool isDiscounted}) async {
    final dio = getPartnersDioClient(
        baseUrl: baseUrl, secureStorage: storage, needAuthorization: true);
    try {
      final response = await dio.put('/product/$uid/discount/',
          queryParameters: {
            'discountedPrice': isDiscounted ? discountedPrice : 0
          });
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
  // Order
  //

  Future<List<Map<String, dynamic>>> getOrderSummaryList(
      {int page = 0,
      int perPage = 10,
      required BackendOrderStatus orderStatusFilter}) async {
    final dio = getPartnersDioClient(
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
    final dio = getPartnersDioClient(
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