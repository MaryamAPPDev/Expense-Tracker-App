import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/category_model.dart';
import '../../features/categories/category_viewmodel.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedIcon = Icons.category.codePoint;
    
    // Some popular icons for categories
    final List<IconData> icons = [
      Icons.category, Icons.fastfood, Icons.directions_car, 
      Icons.shopping_bag, Icons.receipt, Icons.favorite, 
      Icons.attach_money, Icons.flight, Icons.home,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: icons.map((icon) {
                    return ChoiceChip(
                      label: Icon(icon),
                      selected: selectedIcon == icon.codePoint,
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (selected) setState(() => selectedIcon = icon.codePoint);
                      },
                    );
                  }).toList(),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    final cat = CategoryModel(
                      id: const Uuid().v4(),
                      name: nameController.text.trim(),
                      iconCodePoint: selectedIcon,
                    );
                    Provider.of<CategoryViewModel>(context, listen: false).addCategory(cat);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Consumer<CategoryViewModel>(
        builder: (context, vm, child) {
          if (vm.categories.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }
          return ListView.builder(
            itemCount: vm.categories.length,
            itemBuilder: (context, index) {
              final cat = vm.categories[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons')),
                ),
                title: Text(cat.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    vm.deleteCategory(cat.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
