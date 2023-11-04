  import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';

String formatAsCurrency(double value) {
    return '₱ ${toCurrencyString(value.toString())}';
  }