part of 'incle_api.dart';

class OrderProducts {
  final String? couponUid;
  final String productOptionGroupUid;
  final int quantity;

  OrderProducts(
      {this.couponUid,
      required this.productOptionGroupUid,
      required this.quantity});
}
