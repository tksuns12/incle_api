enum OrderProperty { createDate, price, todayGet }
enum OrderValue { ASC, DESC }
enum FindType { Where, Like }
enum FilterType { only, all, exclude }
enum DuplicateProperty { userName, phone, email }
enum OrderStatusEnum {
  preparing,
  onDelivery,
  delivered,
  cancelRequested,
  canceled,
  cancelRejected,
  returnRequested,
  returnRejected,
  returning,
  returned,
  pickedUp,
}
enum DeliveryStatus { beingDelivered, delivered, pickedUp }

extension OrderStatusIntParser on OrderStatusEnum {
  int get value {
    switch (this) {
      case OrderStatusEnum.preparing:
        return 0;
      case OrderStatusEnum.onDelivery:
        return 1;
      case OrderStatusEnum.delivered:
        return 2;
      case OrderStatusEnum.returnRejected:
        return 3;
      case OrderStatusEnum.pickedUp:
        return 4;
      case OrderStatusEnum.cancelRequested:
        return 5;
      case OrderStatusEnum.canceled:
        return 6;
      case OrderStatusEnum.returnRequested:
        return 7;
      case OrderStatusEnum.returned:
        return 8;
      case OrderStatusEnum.returning:
        return 9; 
      default:
        return -1;
    }
  }
}

OrderStatusEnum orderStatusParser(String input) {
  switch (input) {
    case '취소요청':
      return OrderStatusEnum.cancelRequested;
    case '취소확인':
      return OrderStatusEnum.canceled;
    case '배송완료':
      return OrderStatusEnum.delivered;
    case '배송중':
      return OrderStatusEnum.onDelivery;
    case '픽업완료':
      return OrderStatusEnum.pickedUp;
    case '상품준비중':
      return OrderStatusEnum.preparing;
    case '반품거절':
      return OrderStatusEnum.returnRejected;
    case '반품요청':
      return OrderStatusEnum.returnRequested;
    case '반품완료':
      return OrderStatusEnum.returned;
    case '반품승인':
      return OrderStatusEnum.returning;
    default:
      return OrderStatusEnum.preparing;
  }
}

extension Parser on OrderStatusEnum {
  String get string {
    switch (this) {
      case OrderStatusEnum.cancelRequested:
        return '취소요청';
      case OrderStatusEnum.canceled:
        return '취소확인';
      case OrderStatusEnum.delivered:
        return '배송완료';
      case OrderStatusEnum.onDelivery:
        return '배송중';
      case OrderStatusEnum.pickedUp:
        return '픽업완료';
      case OrderStatusEnum.preparing:
        return '상품준비중';
      case OrderStatusEnum.returnRejected:
        return '반품거절';
      case OrderStatusEnum.returnRequested:
        return '반품요청';
      case OrderStatusEnum.returned:
        return '반품완료';
      case OrderStatusEnum.returning:
        return '반품승인';
      default:
        return '잘못된 값';
    }
  }
}

extension FilterIntParser on FilterType {
  int get number {
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
