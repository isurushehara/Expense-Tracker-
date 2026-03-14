import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final limitController = TextEditingController();

  List<Category> categories = [];
  Category? selectedCategory;

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

  Future<void> setBudget() async {
    String? token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse("http://localhost:5000/api/budgets"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token ?? "",
      },

      body: jsonEncode({
        "category_id": selectedCategory?.id,
        "limit_amount": double.parse(limitController.text),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Budget saved")));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Budget")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
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
              controller: limitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Budget Limit"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: setBudget,
              child: const Text("Save Budget"),
            ),
          ],
        ),
      ),
    );
  }
}
