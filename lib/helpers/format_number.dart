import 'package:intl/intl.dart';

String formatNumber(double value, {
  String? locale,
}) {
  double roundedValue = double.parse(value.toStringAsFixed(2));
  NumberFormat formatter = NumberFormat.decimalPattern(locale);
  
  return roundedValue % 1 == 0
      ? formatter.format(roundedValue.toInt())
      : formatter.format(roundedValue);
}