import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../models/transaction_model.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  List<Category> categories = [];
  Category? selectedCategory;

  String type = "expense";

  @override
  void initState() {
    super.initState();

    amountController.text = widget.transaction.amount.toString();
    descriptionController.text = widget.transaction.description;

    type = widget.transaction.type;

    loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await CategoryService.getCategories();

    setState(() {
      categories = data;
    });
  }

  Future<void> updateTransaction() async {
    String? token = await AuthService.getToken();

    final response = await http.put(
      Uri.parse(
        "http://localhost:5000/api/transactions/${widget.transaction.id}",
      ),

      headers: {
        "Content-Type": "application/json",
        "Authorization": token ?? "",
      },

      body: jsonEncode({
        "category_id": selectedCategory?.id,
        "amount": double.parse(amountController.text),
        "type": type,
        "description": descriptionController.text,
        "date": DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Transaction Updated")));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Transaction")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 20),

            DropdownButton<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: "expense", child: Text("Expense")),
                DropdownMenuItem(value: "income", child: Text("Income")),
              ],
              onChanged: (value) {
                setState(() {
                  type = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<Category>(
              hint: const Text("Select Category"),

              value: selectedCategory,

              items: categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat.name));
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: updateTransaction,
              child: const Text("Update Transaction"),
            ),
          ],
        ),
      ),
    );
  }
}
