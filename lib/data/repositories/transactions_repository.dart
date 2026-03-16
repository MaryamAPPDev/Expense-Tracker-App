import 'package:hive/hive.dart';
import '../hive/hive_service.dart';
import '../models/transaction_model.dart';

class TransactionsRepository {
  final Box<TransactionModel> _box = Hive.box<TransactionModel>(HiveService.transactionsBox);

  List<TransactionModel> getAllTransactions() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
