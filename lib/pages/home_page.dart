import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/bar%20graph/bar_graph.dart';
import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helper/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/pages/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  int currentDisplayedMonth = DateTime.now().month;
  late CarouselController carouselController;

  Future<Map<String, double>>? _monthlyTotalFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    refreshData();
    super.initState();
    carouselController = CarouselController();
  }

  void refreshData() {
    _monthlyTotalFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotal();

    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Center(
          child: Text(
            "New Expense",
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: nameController,
              decoration: const InputDecoration(
                  hintText: "Name", hintStyle: TextStyle(color: Colors.white)),
            ),
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: amountController,
              decoration: const InputDecoration(
                  hintText: "Amount",
                  hintStyle: TextStyle(color: Colors.white)),
            )
          ],
        ),
        actions: [
          _cancelButton(),
          _createNewExpenseButton(),
        ],
      ),
    );
  }

  void openEditBox(Expense expense) {
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Center(
            child: Text(
          "Edit",
          style: TextStyle(color: Colors.blueAccent),
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
          _cancelButton(),
          _editExpenseButton(expense),
        ],
      ),
    );
  }

  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Center(
            child: Text(
          "Delete?",
          style: TextStyle(color: Colors.white),
        )),
        actions: [
          Center(
            child: Row(
              children: [
                _cancelButton(),
                _deleteExpenseButton(expense.id),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;
        int monthCount = calculateMonthCount(
            startYear, startMonth, currentYear, currentMonth);
        List<Expense> currentMonthExpense = value.allExpense.where((expense) {
          return expense.date.year == currentYear &&
              expense.date.month == currentMonth;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.black,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
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
                  return Padding(
                    padding: const EdgeInsets.only(left: 85),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${snapshot.data!.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Text('Loading...');
                }
              },
            ),
          ),
          drawer: Drawer(
            backgroundColor: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      height: 125,
                      width: 125,
                      child:
                          Center(child: Image.asset("images/accounting.png")),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const ListTile(
                    leading: Icon(
                      Icons.home,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      'H O M E',
                      style: TextStyle(color: Colors.white),
                    ),
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
                          builder: (context) => const MySettings(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.start,
                    "Yearly Data - $currentYear",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 200,
                    width: 350,
                    child: FutureBuilder(
                      future: _monthlyTotalFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, double> monthlyTotal =
                              snapshot.data ?? {};
                          if (monthlyTotal.isEmpty) {
                            List<double> monthlySummary =
                                List.generate(monthCount, (index) => 0.0);
                            return MyBarGraph(
                                monthlySummary: monthlySummary,
                                startMonth: startMonth);
                          }
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
                        } else {
                          return const Center(
                            child: Text('Loading...'),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Center(
                      child: SizedBox(
                        height: 30,
                        //width: MediaQuery.of(context).size.width,
                        width: 300,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  currentDisplayedMonth =
                                      (currentDisplayedMonth - 2 + 12) % 12 + 1;
                                  carouselController.previousPage();
                                });
                              },
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              height: 60,
                              width: 110,
                              //width: MediaQuery.of(context).size.width - 0,
                              child: CarouselSlider.builder(
                                carouselController: carouselController,
                                itemCount: 12,
                                itemBuilder: (BuildContext context, int index,
                                    int realIndex) {
                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        getCurrentMonthName(index + 1),
                                        style: const TextStyle(
                                            fontSize: 22, color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  height: 40.0,
                                  enlargeCenterPage: true,
                                  onPageChanged: (int index,
                                      CarouselPageChangedReason reason) {
                                    setState(() {
                                      currentDisplayedMonth =
                                          (index + 1) % 12 + 1;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  currentDisplayedMonth =
                                      (currentDisplayedMonth % 12) + 1;
                                  carouselController.nextPage();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentMonthExpense.length,
                      itemBuilder: (context, index) {
                        int reversedIndex =
                            currentMonthExpense.length - 1 - index;
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
          ),
        );
      },
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);
        nameController.clear();
        amountController.clear();
      },
      child: const Text(
        'Cancel',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Navigator.pop(context);
          Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              date: DateTime.now());
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);
          refreshData();
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text(
        'Save',
        style: TextStyle(color: Colors.blueAccent),
      ),
    );
  }

  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          Navigator.pop(context);
          Expense updateExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amountController.text.isNotEmpty
                  ? convertStringToDouble(amountController.text)
                  : expense.amount,
              date: DateTime.now());
          int existingId = expense.id;
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updateExpense);
          refreshData();
        }
      },
      child: const Text(
        'Save',
        style: TextStyle(color: Colors.blueAccent),
      ),
    );
  }

  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<ExpenseDatabase>().deleteExpens(id);
        refreshData();
      },
      child: const Text(
        'Delete',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}
