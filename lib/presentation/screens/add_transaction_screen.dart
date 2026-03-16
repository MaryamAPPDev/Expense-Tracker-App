import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../features/categories/category_viewmodel.dart';
import '../../features/transactions/transaction_viewmodel.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final t = widget.transactionToEdit;
    _titleController = TextEditingController(text: t?.title ?? '');
    _amountController = TextEditingController(text: t != null ? t.amount.toString() : '');
    _noteController = TextEditingController(text: t?.note ?? '');
    _isIncome = t?.isIncome ?? false;
    _selectedDate = t?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
        return;
      }
      
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
        return;
      }

      final transaction = TransactionModel(
        id: widget.transactionToEdit?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: amount,
        isIncome: _isIncome,
        categoryId: _selectedCategory!.id,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      if (widget.transactionToEdit == null) {
        Provider.of<TransactionViewModel>(context, listen: false).addTransaction(transaction);
      } else {
        Provider.of<TransactionViewModel>(context, listen: false).updateTransaction(transaction);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit == null ? 'Add Transaction' : 'Edit Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Toggle
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Expense')),
                  ButtonSegment(value: true, label: Text('Income')),
                ],
                selected: {_isIncome},
                onSelectionChanged: (set) {
                  setState(() => _isIncome = set.first);
                },
              ),
              const SizedBox(height: 16),
              
              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              // Category Dropdown
              Consumer<CategoryViewModel>(
                builder: (context, catVm, child) {
                  if (_selectedCategory == null && widget.transactionToEdit != null) {
                    try {
                      _selectedCategory = catVm.categories.firstWhere((c) => c.id == widget.transactionToEdit!.categoryId);
                    } catch (e) {
                      debugPrint('Category fetch error: $e');
                    }
                  }

                  return DropdownButtonFormField<CategoryModel>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: catVm.categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(IconData(c.iconCodePoint, fontFamily: 'MaterialIcons')),
                            const SizedBox(width: 8),
                            Text(c.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text('Date: ${DateFormat.yMMMd().format(_selectedDate)}'),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Note
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Save Transaction', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
