import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/categories_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoriesRepository _repository;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  CategoryViewModel(this._repository) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await _repository.initDefaultCategories();
    _categories = _repository.getAllCategories();
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _repository.addCategory(category);
    _categories = _repository.getAllCategories();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    _categories = _repository.getAllCategories();
    notifyListeners();
  }
}
