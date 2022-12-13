extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension IntegerExtension on int {
  bool isZero() {
    return this == 0;
  }

  bool isNotZero() {
    return this != 0;
  }
}

extension DoubleExtension on double {
  bool isZero() {
    return this == 0;
  }

  bool isNotZero() {
    return this != 0;
  }
}

extension NumExtension on num {
  bool isZero() {
    return this == 0;
  }

  bool isNotZero() {
    return this != 0;
  }
}

/// NULLABLE EXTENTSION
extension NullableStringExtension on String? {
  String capitalize() {
    return "${this?[0].toUpperCase()}${this?.substring(1).toLowerCase()}";
  }

  bool isNull() {
    return this == null;
  }

  bool isNotNull() {
    return this != null;
  }

  bool isNullOrEmpty() {
    return (this == null) || (this == '');
  }
}

extension NullableIntegerExtension on int? {
  bool isZero() {
    return this == 0;
  }

  bool isNotZero() {
    return this != 0;
  }

  bool isNull() {
    return this == null;
  }

  bool isNotNull() {
    return this != null;
  }

  bool isNullOrZero() {
    return (this == null) || (this == 0);
  }
}

extension NullableDoubleExtension on double? {
  bool isZero() {
    return this == 0;
  }

  bool isNotZero() {
    return this != 0;
  }

  bool isNull() {
    return this == null;
  }

  bool isNotNull() {
    return this != null;
  }

  bool isNullOrZero() {
    return (this == null) || (this == 0);
  }
}

extension NullableNumExtension on num? {
  bool isZero() {
    return this == 0;
  }

  bool isNotZero() {
    return this != 0;
  }

  bool isNull() {
    return this == null;
  }

  bool isNotNull() {
    return this != null;
  }

  bool isNullOrZero() {
    return (this == null) || (this == 0);
  }
}
