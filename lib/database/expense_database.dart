import 'package:expenditure/modules/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _allExpenses = [];

// -->setup
//initialize database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

//-------------------------------------------------------------------------------------------------------------------------------
//-->getters
  List<Expense> get allExpense => _allExpenses;

//-->operations
  //create :- adding
  Future<void> createNewExpense(Expense newExpense) async {
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    await readExpense();
  }

  // re-read from db
  //read-expense from db
  Future<void> readExpense() async {
    List<Expense> fetchedExpense = await isar.expenses.where().findAll();
    //give to local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpense);
    //update ui
    notifyListeners();
  }

  //update
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id; //new expense has same id as existing one

    await isar.writeTxn(() => isar.expenses.put(updatedExpense)); //update in db
    await readExpense(); //re-read
  }

  //delete
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));
    await readExpense();
  }

  //helper

  //calculate total expenses for each month
  Future<Map<String, double>> calculateMonthlyTotals() async {
    await readExpense();

    Map<String, double> monthlyTotals = {};

    //iterate over all expenses
    for (var expense in _allExpenses) {
      String yearMonth = "${expense.date.year}-${expense.date.month}";

      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }

      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }
    return monthlyTotals;
  }

  //get start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );
    return _allExpenses.first.date.month;
  }

  //get start year
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );
    return _allExpenses.first.date.year;
  }

  //calculate current month total
  Future<double> calculateCurrentMonthTotal() async {
    await readExpense();
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    List<Expense> currentMonthExpense = _allExpenses.where((element) {
      return element.date.month == currentMonth &&
          element.date.year == currentYear;
    }).toList();

    double total =
        currentMonthExpense.fold(0, (sum, element) => sum + element.amount);

    return total;
  }
}
