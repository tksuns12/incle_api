part of 'incle_api.dart';

enum OrderProperty { createDate, price, todayGet, subscriberCount }

enum OrderValue { ASC, DESC }

enum FindType { Where, Like }

enum FilterType { only, all, exclude }

enum DuplicateProperty { userName, phone, email }

enum Gender { male, female }

extension GenderToString on Gender {
  String toJsonString() {
    switch (this) {
      case Gender.female:
        return 'F';
      case Gender.male:
        return 'M';
      default:
        throw UnimplementedError();
    }
  }
}

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

enum NoticeTarget { CLIENT, PARTNERS }

extension OrderStatusIntParser on OrderStatusEnum {
  String get serverFormat {
    switch (this) {
      case OrderStatusEnum.preparing:
        return 'PREARE';
      case OrderStatusEnum.onDelivery:
        return 'SHIPPING';
      case OrderStatusEnum.delivered:
        return 'DELIVERY_COMPLETE';
      case OrderStatusEnum.returnRejected:
        return 'RETURN_REFUSE';
      case OrderStatusEnum.pickedUp:
        return 'PICKUP_COMPLETE';
      case OrderStatusEnum.cancelRequested:
        return 'CANCEL_REQUEST';
      case OrderStatusEnum.canceled:
        return 'CANCEL_COMPLETE';
      case OrderStatusEnum.returnRequested:
        return 'RETURN_REQUEST';
      case OrderStatusEnum.returned:
        return 'RETURN_COMPLETE';
      case OrderStatusEnum.returning:
        return 'RETURN_APPROVE';
      default:
        return 'WRONG_VALUE';
    }
  }
}

OrderStatusEnum orderStatusParser(String input) {
  switch (input) {
    case '취소요청':
    case '취소신청':
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
