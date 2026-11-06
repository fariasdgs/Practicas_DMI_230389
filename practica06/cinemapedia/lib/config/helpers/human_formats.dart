import 'package:intl/intl.dart';

class HumanFormats {
  static String number(double number) => NumberFormat.compact().format(number);
}
