import 'package:isar/isar.dart';
//to create expense.g.dart run cmd "dart run build_runner build"
part 'expense.g.dart';//creates isar file a local database
@Collection()
class Expense {
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime date;

  Expense({
    required this.name,
    required this.amount,
    required this.date,
  });
}
