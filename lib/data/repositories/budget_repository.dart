import 'package:hive/hive.dart';
import '../hive/hive_service.dart';

class BudgetRepository {
  final Box _box = Hive.box(HiveService.budgetBox);

  double get monthlyBudget => _box.get('monthlyBudget', defaultValue: 0.0);
  Future<void> setMonthlyBudget(double value) async => await _box.put('monthlyBudget', value);
}
