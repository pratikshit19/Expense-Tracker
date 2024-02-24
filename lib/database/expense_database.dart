import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _allExpenses = [];

/*
 S E T U P
*/

//initial db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

/*

G E T T E R S

 */

  List<Expense> get allExpense => _allExpenses;

/*

O P E R A T I O N S 

 */
//create
  Future<void> createNewExpense(Expense newExpense) async {
    //add to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    //re-read from db
    await readExpenses();
  }

//read
  Future<void> readExpenses() async {
    //fetch all existing expenses from db
    List<Expense> fetchedExpenes = await isar.expenses.where().findAll();

    //give to local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenes);

    //update ui
    notifyListeners();
  }

//update
  Future<void> updateExpense(int id, Expense updateExpense) async {
    //make sure new expene has same id as existing one
    updateExpense.id = id;

    //update in db
    await isar.writeTxn(() => isar.expenses.put(updateExpense));

    //re-read from db
    await readExpenses();
  }

//delete
  Future<void> deleteExpens(int id) async {
    //delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));

    //re-read from db
    await readExpenses();
  }

  /*

H E L P E R 

 */

//CALCULATE TOTAL EXPENSE FOR EACH MONTH
  Future<Map<String, double>> calculateMonthlyTotal() async {
    //ensure expenses are read from db
    await readExpenses();

    //create a map to keep track of th total expenses per month
    Map<String, double> monthlyTotal = {};

    //itrerate over all epxenses
    for (var expense in _allExpenses) {
      //extract year & month from date of the expense
      String yearMonth = '${expense.date.year}-${expense.date.month}';

      //if year & month is not yet in the map, init to 0
      if (!monthlyTotal.containsKey(yearMonth)) {
        monthlyTotal[yearMonth] = 0;
      }
      //add expense amount to the total for the month
      monthlyTotal[yearMonth] = monthlyTotal[yearMonth]! + expense.amount;
    }
    return monthlyTotal;
  }

  //calculate the current month total
  Future<double> calculateCurrentMonthTotal() async {
    //ensure expenses are read from db first
    await readExpenses();

    //get current month, yr
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    //filter the expense to include only this month and this year
    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth &&
          expense.date.year == currentYear;
    }).toList();

    //calculate total amount for current month
    double total =
        currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);
    return total;
  }

  //gt start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    //sort expense by date to ffind the earliest expense
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.month;
  }

  //get start year
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    //sort expense by date to ffind the earliest expense
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.year;
  }
}
