import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  List<Category> categories = [];
  Category? selectedCategory;

  String type = "expense";

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await CategoryService.getCategories();

    setState(() {
      categories = data;
    });
  }

  Future<void> addTransaction() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }

    String? token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse("http://localhost:5000/api/transactions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token ?? "",
      },
      body: jsonEncode({
        "category_id": selectedCategory!.id,

        "amount": double.parse(amountController.text),

        "type": type,

        "description": descriptionController.text,

        "date": DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Transaction Added")));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error adding transaction")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),

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
              onPressed: addTransaction,
              child: const Text("Save Transaction"),
            ),
          ],
        ),
      ),
    );
  }
}
