enum OrderProperty { createdDate, price, todayGet }
enum OrderValue { ASC, DESC }
enum FindType { Where, Like }
enum FilterType { only, all, exclude }
enum DuplicateProperty { userName, phone, email }
enum BackendOrderStatus {
  all,
  preparing,
  delivering,
  delivered,
  deliveredOrDelivering,
  problem
}
enum DeliveryStatus {beingDelivered, delivered, pickedUp}

extension OrderStatusIntParser on BackendOrderStatus {
  int get value {
    switch (this) {
      case BackendOrderStatus.all:
        return 0;
      case BackendOrderStatus.preparing:
        return 1;
      case BackendOrderStatus.delivering:
        return 2;
      case BackendOrderStatus.delivered:
        return 3;
      case BackendOrderStatus.deliveredOrDelivering:
        return 4;
      case BackendOrderStatus.problem:
        return 5;
    }
  }
}

extension FilterIntParser on FilterType {
  int get value {
    switch (this) {
      case FilterType.only:
        return 1;
      case FilterType.all:
        return 0;
      case FilterType.exclude:
        return -1;
    }
  }
}
