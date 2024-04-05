import 'package:intl/intl.dart';

//convert string to double
double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

//format double amount into Rs
String formatAmount(double amount) {
  final format = NumberFormat.currency(
    name: "INR",
    locale: 'en_IN',
    decimalDigits: 2, // change it to get decimal places
    symbol: '₹ ',
  );
  return format.format(amount);
}

//calculate the number of months since the first start month
int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount =
      (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

//get current month name
String getCurrentMonthName() {
  DateTime now = DateTime.now();
  List<String> months = [
    "JANUARY",
    "FEBRUARY",
    "MARCH",
    "APRIL",
    "MAY",
    "JUNE",
    "JULY",
    "AUGUST",
    "SEPTEMBER",
    "OCTOBER",
    "NOVEMBER",
    "DECEMBER",
  ];

  return months[now.month - 1];
}
