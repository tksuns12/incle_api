part of 'incle_api.dart';

class StoreWiseOrderProducts {
  final String couponUid;
  final Map<String, int> productOptionGroupUidQuantity;

  StoreWiseOrderProducts(
      {required this.couponUid, required this.productOptionGroupUidQuantity});
}
