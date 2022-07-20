part of 'incle_api.dart';

class OrderProducts {
  final String? couponUid;
  final String productOptionGroupUid;
  final int quantity;

  OrderProducts(
      {this.couponUid,
      required this.productOptionGroupUid,
      required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'productOptionGroupUid': productOptionGroupUid,
      'count': quantity,
      'couponUid': couponUid
    };
  }
}

class ListWithMaxCount {
  final List data;
  final int maxCount;

  ListWithMaxCount(this.data, this.maxCount);
}
