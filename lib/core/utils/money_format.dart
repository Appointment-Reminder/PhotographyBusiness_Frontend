/// Prints [value] without decimals when it is whole, with two otherwise.
String formatAmount(num value) =>
    value == value.truncate() ? value.toInt().toString() : value.toStringAsFixed(2);
