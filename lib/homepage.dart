import 'package:expenditure/bar%20graph/bar_graph.dart';
import 'package:expenditure/components/list_tile.dart';
import 'package:expenditure/database/expense_database.dart';
import 'package:expenditure/helper/helper.dart';
import 'package:expenditure/modules/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

//future to load bar graph
  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpense();
    refreshGraph();
    super.initState();
  }

  //refresh graph data
  void refreshGraph() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();

    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  //open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Expense",
              ),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                hintText: "Amount",
              ),
            )
          ],
        ),
        actions: [
          _cancelButton(),
          _saveButton(),
        ],
      ),
    );
  }

//open editBox
  void openEditBox(Expense expense) {
    String existingExpense = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: existingExpense,
              ),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                hintText: existingAmount,
              ),
            )
          ],
        ),
        actions: [
          _cancelButton(),
          _editButton(expense),
        ],
      ),
    );
  }

  //openDelete Box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        actions: [
          _cancelButton(),
          _deleteButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      //get dates
      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      //cal the no. of months since the frist month
      int monthCount =
          calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      //display expenses for the current month
      List<Expense> currentMonthExpense = value.allExpense.where(
        (element) {
          return element.date.year == currentYear &&
              element.date.month == currentMonth;
        },
      ).toList();

      return Scaffold(
        backgroundColor: Colors.grey.shade300,
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            "Expenditure",
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                child: FutureBuilder<double>(
                  future: _calculateCurrentMonthTotal,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(getCurrentMonthName()),
                            Text("₹${snapshot.data!.toStringAsFixed(2)}"),
                          ],
                        ),
                      );
                    } else {
                      return const Text("loading...");
                    }
                  },
                ),
              ),
              //graph
              SizedBox(
                height: 250,
                child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapsot) {
                      //data loaded
                      if (snapsot.connectionState == ConnectionState.done) {
                        Map<String, double> monthlyTotals = snapsot.data ?? {};

                        List<double> monthlySummary =
                            List.generate(monthCount, (index) {
                          int year = startYear + (startMonth + index - 1) ~/ 12;
                          int month = (startMonth + index) % 12 + 1;

                          String yearMonthKey = '$year-$month';
                          return monthlyTotals[yearMonthKey] ?? 0.0;
                        });

                        return MyBarGraph(
                            monthlySummary: monthlySummary,
                            startMonth: startMonth);
                      } else {
                        //data loading..
                        return const Center(
                          child: Text("Loading"),
                        );
                      }
                    }),
              ),
              const SizedBox(height: 25),
              //Expense List
              Expanded(
                child: ListView.builder(
                  itemCount: currentMonthExpense.length,
                  itemBuilder: (context, index) {
                    int reverseIndex = currentMonthExpense.length -
                        1 -
                        index; //shows the lsit in reverse order

                    Expense individualExpense =
                        currentMonthExpense[reverseIndex];
                    return MyListTile(
                      name: individualExpense.name,
                      amount: formatAmount(individualExpense.amount),
                      onEditPressed: (context) =>
                          openEditBox(individualExpense),
                      onDeletePressed: (context) =>
                          openDeleteBox(individualExpense),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);
        nameController.clear();
        amountController.clear();
      },
      child: const Text("Cancel"),
    );
  }

  Widget _saveButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Navigator.pop(context);
          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );
          //save to db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);
          refreshGraph();
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  //_editButton
  Widget _editButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          Navigator.pop(context);
          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringToDouble(amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );
          int existingId = expense.id;
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);
          refreshGraph();
        }
      },
      child: const Text("Save"),
    );
  }

  //_deleteButton
  Widget _deleteButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<ExpenseDatabase>().deleteExpense(id);
        refreshGraph();
      },
      child: const Text("Delete"),
    );
  }
}
