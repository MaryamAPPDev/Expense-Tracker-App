import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../hive/hive_service.dart';
import '../models/category_model.dart';

class CategoriesRepository {
  final Box<CategoryModel> _box = Hive.box<CategoryModel>(HiveService.categoriesBox);

  List<CategoryModel> getAllCategories() {
    return _box.values.toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _box.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }

  Future<void> initDefaultCategories() async {
    if (_box.isEmpty) {
      final defaultCats = [
        CategoryModel(id: '1', name: 'Food', iconCodePoint: Icons.fastfood.codePoint),
        CategoryModel(id: '2', name: 'Transport', iconCodePoint: Icons.directions_car.codePoint),
        CategoryModel(id: '3', name: 'Shopping', iconCodePoint: Icons.shopping_bag.codePoint),
        CategoryModel(id: '4', name: 'Bills', iconCodePoint: Icons.receipt.codePoint),
        CategoryModel(id: '5', name: 'Health', iconCodePoint: Icons.favorite.codePoint),
        CategoryModel(id: '6', name: 'Salary', iconCodePoint: Icons.attach_money.codePoint),
      ];
      for (var cat in defaultCats) {
        await _box.put(cat.id, cat);
      }
    }
  }
}
