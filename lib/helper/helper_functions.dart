import 'package:intl/intl.dart';

//Convert string to double
double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

//format double to rupees
String formatAmount(double amount) {
  final format =
      NumberFormat.currency(locale: "en_IN", symbol: "₹", decimalDigits: 2);
  return format.format(amount);
}

//calcaulate the number of months since first month
int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount =
      (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

//get current month name
String getCurrentMonthName(int currentDisplayedMonth) {
  DateTime now = DateTime.now();
  List<String> months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC"
  ];
  return months[now.month - 1];
}
