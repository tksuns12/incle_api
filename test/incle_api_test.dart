import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incle_api/incle_api.dart';

void main() {
  test('test health_check', () async {
    final client = InclePartnersAPI();
    final result = await client.isServerHealthy();
    expect(result, isA<bool>());
  });

  group('test isHoliday', () {
    test('test isHoliday with korean independence campaign day', () async {
      // Arrange
      InclePartnersAPI.initialize();
      final client = InclePartnersAPI();
      WidgetsFlutterBinding.ensureInitialized();
      // Act
      final result = await client.holidayCheck('2022', '03', '01');
      // Assert
      expect(result, true);
    });
  });
}
