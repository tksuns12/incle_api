import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incle_api/incle_api.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_services.dart';

void main() {
  final mockStorage = MockFlutterSecureStoreage();

  test('test health_check', () async {
    final client = InclePartnersAPI(mockStorage);

    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    final result = await client.isServerHealthy();
    expect(result, isA<bool>());
  });

  test('test login - not approved', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.login('notallow', 'notallow');
    // Assert
    print(result.toString());
  });

  group('test isHoliday', () {
    test('test isHoliday with korean independence campaign day', () async {
      // Arrange
      final client = InclePartnersAPI(mockStorage);
      when(() => mockStorage.read(key: 'id'))
          .thenAnswer((invocation) async => 'testpartners');
      when(() => mockStorage.read(key: 'password'))
          .thenAnswer((invocation) async => 'testpartners');
      when(
          () =>
              mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
      
      // Act
      final result = await client.holidayCheck('2022', '03', '01');
      // Assert
      expect(result, true);
    });

    test('test isHoliday with normal day', () async {
      // Arrange
      final client = InclePartnersAPI(mockStorage);
      when(() => mockStorage.read(key: 'id'))
          .thenAnswer((invocation) async => 'testpartners');
      when(() => mockStorage.read(key: 'password'))
          .thenAnswer((invocation) async => 'testpartners');
      when(
          () =>
              mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
      
      // Act
      final result = await client.holidayCheck('2022', '03', '03');
      // Assert
      expect(result, false);
    });
  });

  group('test signup', () {
    test('signup successfully', () async {
      // Arrange
      final client = InclePartnersAPI(mockStorage);
      
      when(
          () =>
              mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
      // Act
      final result = await client.signup(
        accountNumber: '3333017381547',
        accountOwner: '김사장',
        bank: '신한은행',
        businessNumber: '7840734638',
        closeTime: '22:00',
        dayoffs: [
          [false, false, false, false, true, true],
          [false, false, false, false, true, true],
          [false, false, false, false, true, true],
          [false, false, false, false, true, true],
          [false, false, false, false, true, true],
        ],
        email: 'tksuns@gmail.com',
        id: 'testpartner',
        isRestHolidy: true,
        latitude: 127.0652438,
        longitude: 37.4885214,
        name: '김사장',
        openTime: '10:00',
        ownerName: '김사장',
        password: 'testpartner',
        phoneNumber: '01039481923',
        postCode: '23456',
        storeAddress1: '경남 진주시 석갑로 58',
        storeAddress2: '신안아파트 302동 201호',
        storeCategories: 'all',
        storeDescription: '가게입니다. 가게입니다.',
        storeName: '인클샵',
        storePhone: '0534852345',
        registration: File('test_resources/registration.jpeg'),
        registration2: File('test_resources/registration.jpeg'),
        storePictures: [File('test_resources/image1.jpeg')],
      );
      // Assert
      expect(result['statusCode'], 201);
    }, timeout: const Timeout(Duration(minutes: 1)));
  });

  test('test updateProfile', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.updateProfile(
      accountNumber: '3333017381547',
      accountOwner: '김사장',
      bank: '신한은행',
      businessNumber: '7890123456',
      closeTime: '22:00',
      dayoffs: [
        [false, false, false, false, true, true],
        [false, false, false, false, true, true],
        [false, false, false, false, true, true],
        [false, false, false, false, true, true],
        [false, false, false, false, true, true],
      ],
      email: 'tksuns@gmail.com',
      id: 'testpartner',
      isRestHolidy: true,
      latitude: 127.0652438,
      longitude: 37.4885214,
      name: '김사장',
      openTime: '10:00',
      ownerName: '김사장',
      password: 'testpartner',
      phoneNumber: '01039481923',
      postCode: '23456',
      storeAddress1: '경남 진주시 석갑로 58',
      storeAddress2: '신안아파트 302동 201호',
      storeCategories: 'all',
      storeDescription: '가게입니다. 가게입니다.',
      storeName: '인클샵',
      storePhone: '0534852345',
      registration: File('test_resources/registration.jpeg'),
      registration2: File('test_resources/registration.jpeg'),
      storePictures: [File('test_resources/image1.jpeg')],
    );
    // Assert
    print(result.toString());
  });

  test('test getPartnersProfile', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.getPartnersProfile();
    // Assert
    print(result.toString());
  });

  test('test checkVerifyNum', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.checkVerifyNum('01093840103', '1111');
    // Assert
    print(result.toString());
  });

  test('test findPasswordAllow', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.findPasswordAllow(
        email: 'email@email.com', phone: '01012341234', name: 'teststore');
    // Assert
    print(result.toString());
  });

  test('test findPassword', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result =
        await client.finidPassword('198237498alksdj;fkl', 'nwePassword');
    // Assert
    print(result.toString());
  });

  test('test findID', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result =
        await client.findId('email@email.com', 'teststore', '01012341234');
    // Assert
    print(result.toString());
  });

  group('test DuplicateCheck', () {
    test('test ID DuplicateCheck', () async {
      // Arrange
      final client = InclePartnersAPI(mockStorage);
      
      when(
          () =>
              mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
      // Act
      final result = await client.duplicateCheck('id', 'tksuns12');
      // Assert
      expect(result['data'], true);
    });

    test('test Email DuplicateCheck', () async {
      // Arrange
      final client = InclePartnersAPI(mockStorage);
      
      when(
          () =>
              mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
      // Act
      final result = await client.duplicateCheck('email', 'email@email.com');
      // Assert
      expect(result['data'], true);
    });

    test('test phoneNumber DuplicateCheck', () async {
      // Arrange
      final client = InclePartnersAPI(mockStorage);
      
      when(
          () =>
              mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
      // Act
      final result = await client.duplicateCheck('phone', '01012341234');
      // Assert
      expect(result['data'], true);
    });
  });

  test('test sendVerifyNum', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.sendVerifyNum('01012341234');
    // Assert
    print(result.toString());
  });

  test('test createCoupon without limit date', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.createCoupon(
      'specialCupon',
      1000,
      10000,
    );
    // Assert
    print(result.toString());
  });

  test('test createCoupon with limit date', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.createCoupon(
        'specialCoupon3', 1000, 10000, DateTime(2023,03,04));
    // Assert
    print(result.toString());
  });

  test('test getCouponList', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.getCouponList();
    // Assert
    print(result.toString());
  });

  test('test deleteCoupon', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.deleteCoupon('5');
    // Assert
    print(result.toString());
  });

  test('test getDeliver', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.getDeliver();
    // Assert
    print(result.toString());
  });

  test('test updateDeliver', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.updateDeliver(
        deliveryConditions: {2: 3000, 3: 4000, 4: 5000}, freeCondition: 50000);
    // Assert
    print(result.toString());
  });

  test('test unpausePartner', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.unpausePartners();
    // Assert
    print(result.toString());
  });

  test('test pausePartners', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.pausePartners(
        TimeOfDay.now(), const TimeOfDay(hour: 22, minute: 30));
    // Assert
    print(result.toString());
  });

  test('test uploadProduct', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.uploadProduct(
      name: '테스트 블라우',
      price: '30000',
      todayGet: false,
      images: [
        File('test_resources/image1.jpeg'),
        File('test_resources/image2.jpeg'),
        File('test_resources/image3.jpeg')
      ],
      description: '테스트용 블라우스입니다. 예뻐요. 예뻐요.',
      modelHeight: 165,
      modelWeight: 43,
      modelSize: '44',
      modelNormalSize: '44',
      options: {
        'options': [
          {
            '사이즈': ['S', 'M', 'L']
          },
          {
            '색상': ['빨강', '파랑']
          }
        ],
        'stocks': [
          {
            'options': ['S', '빨강'],
            'stock': 10
          },
          {
            'options': ['S', '파랑'],
            'stock': 200
          },
          {
            'options': ['M', '파랑'],
            'stock': 20
          },
          {
            'options': ['M', '빨강'],
            'stock': 20
          },
          {
            'options': ['L', '빨강'],
            'stock': 20
          },
          {
            'options': ['L', '파랑'],
            'stock': 20
          },
        ]
      },
      cody: ['1', '2', '3'],
    );
    // Assert
    print(result.toString());
  });

  group('test getPartnersProductList', () {
    test('test getPartnersProductList', () async {
      // Arrange
      final client = InclePartnersAPI(mockStorage);
      
      when(
          () =>
              mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
      // Act
      final result = await client.getPartnersProductList();
      // Assert
      print(result.toString());
    });

    test('test getPartnersProductList for discounted products', () async {
      // Arrange
      final client = InclePartnersAPI(mockStorage);
      
      when(
          () =>
              mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
      // Act
      final result = await client.getPartnersProductList(discountOnly: true);
      // Assert
      print(result.toString());
    });

    test('test getPartnersProductList for the recommended', () async {
      // Arrange
      final client = InclePartnersAPI(mockStorage);
      
      when(
          () =>
              mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
      // Act
      final result = await client.getPartnersProductList(recommendedOnly: true);
      // Assert
      print(result.toString());
    });
  });

  test('test updateProduct', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.updateProduct(
      uid: 'b7076e30-6001-4844-beaa-aa5effbc8ae8',
      name: '테스트 블라우스',
      price: '30000',
      todayGet: false,
      images: [
        File('test_resources/image1.jpeg'),
        File('test_resources/image2.jpeg'),
        File('test_resources/image3.jpeg')
      ],
      description: '테스트용 블라우스입니다. 수정했습니다잉.',
      modelHeight: 165,
      modelWeight: 43,
      modelSize: '44',
      modelNormalSize: '44',
      options: {
        'options': [
          {
            '사이즈': ['S', 'M', 'L']
          },
          {
            '색상': ['빨강', '파랑']
          }
        ],
        'stocks': [
          {
            'options': ['S', '빨강'],
            'stock': 10
          },
          {
            'options': ['S', '파랑'],
            'stock': 200
          },
          {
            'options': ['M', '파랑'],
            'stock': 20
          },
          {
            'options': ['M', '빨강'],
            'stock': 20
          },
          {
            'options': ['L', '빨강'],
            'stock': 20
          },
          {
            'options': ['L', '파랑'],
            'stock': 20
          },
        ]
      },
      cody: ['1', '2', '3'],
    );
    // Assert
    print(result.toString());
  });

  test('test deleteProduct', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.deleteProduct(
      uid: 'b7076e30-6001-4844-beaa-aa5effbc8ae8',
    );
    // Assert
    print(result.toString());
  });

  test('test soldoutProduct', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.soldoutProduct(
      uid: 'f9af2aa7-a245-49a6-a62a-75da1af3572d',
      options: ['S', '빨강'],
    );
    // Assert
    print(result.toString());
  });

  test('test addProductOwnersRecommend', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.addProductOwnersRecommend(
        uid: 'f9af2aa7-a245-49a6-a62a-75da1af3572d');
    // Assert
    print(result.toString());
  });

  test('test addProductDiscount', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.addProductDiscount(
        uid: 'f9af2aa7-a245-49a6-a62a-75da1af3572d', discountedPrice: 20000);
    // Assert
    print(result.toString());
  });

  test('test deleteProductOwnersRecommended', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.deleteProductOwnersRecommended(
        uid: 'f9af2aa7-a245-49a6-a62a-75da1af3572d');
    // Assert
    print(result.toString());
  });

  test('test deleteProductDiscount', () async {
    // Arrange
    final client = InclePartnersAPI(mockStorage);
    
    when(() => mockStorage.read(key: 'token')).thenAnswer((invocation) async =>
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4MjUwMWE5LTc0ZDgtNGI0Yy1hMzRiLTI1ZWRjNGY1YjJlYyIsImlhdCI6MTY0NTc1NTA1OCwiZXhwIjo1MjQ1NzU1MDU4fQ.jPt7oFHB2ZRtIj60fjAwm91T8CuSJpMCBrDF-fyG_sw');
    // Act
    final result = await client.deleteProductDiscount(
        uid: 'f9af2aa7-a245-49a6-a62a-75da1af3572d');
    // Assert
    print(result.toString());
  });

}
