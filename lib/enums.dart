enum OrderProperty { createdDate, price, todayGet }
enum OrderValue { ASC, DESC }
enum FindType { Where, Like }
enum FilterType { only, all, exclude }
enum DuplicateProperty {userName, phone, email}

extension IntParser on FilterType {
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
