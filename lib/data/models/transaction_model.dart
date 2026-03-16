import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final bool isIncome;

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.categoryId,
    required this.date,
    this.note,
  });
}
