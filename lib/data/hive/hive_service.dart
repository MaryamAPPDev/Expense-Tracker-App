import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class HiveService {
  HiveService._();

  static const String transactionsBox = 'transactionsBox';
  static const String categoriesBox = 'categoriesBox';
  static const String settingsBox = 'settingsBox';
  static const String budgetBox = 'budgetBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }

    await Hive.openBox<TransactionModel>(transactionsBox);
    await Hive.openBox<CategoryModel>(categoriesBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(budgetBox);
  }
}
