import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transactions_repository.dart';
import '../categories/category_viewmodel.dart';
import '../../data/models/category_model.dart';
import 'package:csv/csv.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionsRepository _repository;
  final CategoryViewModel _categoryViewModel;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  double get totalBalance => totalIncome - totalExpense;

  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  TransactionViewModel(this._repository, this._categoryViewModel) {
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactions = _repository.getAllTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
    _loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repository.updateTransaction(transaction);
    _loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    _loadTransactions();
  }

  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }

  CategoryModel? getCategory(String categoryId) {
    try {
      return _categoryViewModel.categories.firstWhere(
        (c) => c.id == categoryId,
      );
    } catch (e) {
      return null;
    }
  }

  List<TransactionModel> searchTransactions(String query) {
    if (query.isEmpty) return _transactions;
    return _transactions
        .where(
          (t) =>
              t.title.toLowerCase().contains(query.toLowerCase()) ||
              (t.note?.toLowerCase().contains(query.toLowerCase()) ?? false),
        )
        .toList();
  }

  Future<String> exportToCSV() async {
    List<List<dynamic>> rows = [];
    rows.add(["ID", "Title", "Amount", "Type", "Category", "Date", "Note"]);

    for (var t in _transactions) {
      final category = getCategory(t.categoryId)?.name ?? 'Unknown';
      rows.add([
        t.id,
        t.title,
        t.amount,
        t.isIncome ? "Income" : "Expense",
        category,
        t.date.toIso8601String(),
        t.note ?? "",
      ]);
    }

    String csv = "";

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/transactions.csv";
    final file = File(path);
    await file.writeAsString(csv);
    return path;
  }
}
