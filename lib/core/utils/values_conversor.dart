// Converts a dynamic value to int if possible, otherwise returns null.
int? valueToInt(dynamic value) {
  if (value == null) {
    return null;
  }
  switch (value.runtimeType) {
    case int:
      return value.toInt();
    case num:
      return value.toInt();
    case String:
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();

    default:
      return int.tryParse(value.toString()) ??
          double.tryParse(value.toString())?.toInt();
  }
}

// Converts a dynamic value to double if possible, otherwise returns null.
double? valueToDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  switch (value.runtimeType) {
    case double:
      return value.toDouble();
    case int:
      return value.toDouble();
    case num:
      return value.toDouble();
    case String:
      return double.tryParse(value);

    default:
      return double.tryParse(value.toString());
  }
}

// Converts a dynamic value to String if possible, otherwise returns null.
String? valueToString(dynamic value) {
  if (value == null) {
    return null;
  }
  switch (value.runtimeType) {
    case String:
      return value;
    case int:
    case double:
    case num:
      return value.toString();

    default:
      return value.toString();
  }
}
