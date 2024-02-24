import 'package:expense_tracker/bar%20graph/bar_graph.dart';
import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helper/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  //futures to load graph data
  Future<Map<String, double>>? _monthlyTotalFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    //read db on intial startup
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    //load futures
    refreshData();

    super.initState();
  }

  //refresh graph data
  void refreshData() {
    _monthlyTotalFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotal();

    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  //open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "New Expense",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  hintText: "Name", hintStyle: TextStyle(color: Colors.white)),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                  hintText: "Amount",
                  hintStyle: TextStyle(color: Colors.white)),
            )
          ],
        ),
        actions: [
          //cancel btn
          _cancelButton(),
          //save btn
          _createNewExpenseButton(),
        ],
      ),
    );
  }

  //open edit box
  void openEditBox(Expense expense) {
    //prefill the existing values
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Center(
            child: Text(
          "Edit",
          style: TextStyle(color: Colors.white),
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                  hintText: existingName,
                  hintStyle: const TextStyle(color: Colors.white)),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                  hintText: existingAmount,
                  hintStyle: const TextStyle(color: Colors.white)),
            )
          ],
        ),
        actions: [
          //cancel btn
          _cancelButton(),
          //save btn
          _editExpenseButton(expense),
        ],
      ),
    );
  }

  //open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Center(
            child: Text(
          "Delete?",
          style: TextStyle(color: Colors.white),
        )),
        actions: [
          //cancel btn
          _cancelButton(),
          //delete btn
          _deleteExpenseButton(expense.id),
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

      //calcuate the number of months since the first month
      int monthCount =
          calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      //only display the expenses of the current month
      List<Expense> currentMonthExpense = value.allExpense.where((expense) {
        return expense.date.year == currentYear &&
            expense.date.month == currentMonth;
      }).toList();

      //return ui
      return Scaffold(
          backgroundColor: Colors.black,
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromRGBO(12, 77, 223, 0.612),
            foregroundColor: Colors.white,
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            backgroundColor: Colors.transparent,
            title: FutureBuilder<double>(
                future: _calculateCurrentMonthTotal,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // ignore: prefer_interpolation_to_compose_strings
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 85,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${snapshot.data!.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent),
                          ),
                          Text(
                            getCurrentMonthName(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Text('Loading...');
                  }
                }),
          ),
          drawer: Drawer(
            backgroundColor: Colors.black,
            // Drawer content goes here
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(
                children: [
                  const ListTile(
                    leading: Icon(
                      Icons.home,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      'H O M E',
                      style: TextStyle(color: Colors.white),
                    ),
                    // Add your onPressed logic for Drawer Item 1
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: Colors.blueAccent,
                    ),
                    title: const Text(
                      'S E T T I N G S',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const MySettings(), // Assuming SettingsPage is your settings.dart page
                        ),
                      );
                    },
                    // Add your onPressed logic for Drawer Item 2
                  ),
                  // Add more ListTiles for additional drawer items
                ],
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(
              top: 25,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  //GRAPH UI
                  SizedBox(
                    height: 250,
                    width: 350,
                    child: FutureBuilder(
                      future: _monthlyTotalFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, double> monthlyTotal =
                              snapshot.data ?? {};

                          // Check if monthlyTotal is empty, provide default values
                          if (monthlyTotal.isEmpty) {
                            List<double> monthlySummary =
                                List.generate(monthCount, (index) => 0.0);
                            return MyBarGraph(
                                monthlySummary: monthlySummary,
                                startMonth: startMonth);
                          }
                          // Create list of monthly summary
                          List<double> monthlySummary =
                              List.generate(monthCount, (index) {
                            int year =
                                startYear + (startMonth + index - 1) ~/ 12;
                            int month = (startMonth + index - 1) % 12 + 1;

                            String yearMonthKey = '$year-$month';
                            return monthlyTotal[yearMonthKey] ?? 0.0;
                          });

                          return MyBarGraph(
                              monthlySummary: monthlySummary,
                              startMonth: startMonth);
                        }

                        // Loading...
                        else {
                          return const Center(
                            child: Text('Loading...'),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),

                  //EXPENSE LIST UI
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentMonthExpense.length,
                      itemBuilder: (context, index) {
                        //reverse the index to show latest expense
                        int reversedIndex =
                            currentMonthExpense.length - 1 - index;
                        //get individual expenses
                        Expense individualExpense =
                            currentMonthExpense[reversedIndex];
                        return MyListTile(
                          title: individualExpense.name,
                          trailing: formatAmount(individualExpense.amount),
                          onEditPressed: (context) =>
                              openEditBox(individualExpense),
                          onDeletePressed: (context) =>
                              openDeleteBox(individualExpense),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ));
    });
  }

  //CANCEL BUTTON
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        //clear contrllers
        nameController.clear();
        amountController.clear();
      },
      child: const Text(
        'Cancel',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  //SAVE BUTTON
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        //only save if something in textfield
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //create new expense
          Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              date: DateTime.now());

          //save to db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          //refresh the graph
          refreshData();

          //clear cntrollers
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text(
        'Save',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  //EDIT EXPENSE BUTTON
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        //save as long as 1 txtfield is changed
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //created update expense
          Expense updateExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amountController.text.isNotEmpty
                  ? convertStringToDouble(amountController.text)
                  : expense.amount,
              date: DateTime.now());

          //old expense id
          int existingId = expense.id;

          //save to db
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updateExpense);
          //refresh the graph
          refreshData();
        }
      },
      child: const Text(
        'Save',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  //DELETE EXPENSE BUTTON
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        //pop box
        Navigator.pop(context);

        //delete expense from db
        await context.read<ExpenseDatabase>().deleteExpens(id);

        //refresh the graph
        refreshData();
      },
      child: const Text(
        'Delete',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
