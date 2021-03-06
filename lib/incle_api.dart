library incle_api;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:tuple/tuple.dart';
import 'dio_client.dart';
import 'package:http_parser/http_parser.dart';
part 'package:incle_api/enums.dart';
part 'incle_client_api.dart';
part 'incle_general_api.dart';
part 'incle_partners_api.dart';
part 'data.dart';

class IncleAPI {
  IncleClientAPI? _clientService;
  InclePartnersAPI? _partnersService;
  IncleGeneralAPI? _generalService;

  final _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions.defaultOptions);

  IncleClientAPI get clientService {
    _clientService ??= IncleClientAPI(_secureStorage);
    return _clientService!;
  }

  InclePartnersAPI get partnersService {
    _partnersService ??= InclePartnersAPI(_secureStorage);
    return _partnersService!;
  }

  IncleGeneralAPI get generalService {
    _generalService ??= IncleGeneralAPI(_secureStorage);
    return _generalService!;
  }
}
