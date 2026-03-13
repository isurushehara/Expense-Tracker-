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
    loadCategories().then((_) {
      setState(() {
        selectedCategory = categories.firstWhere(
          (c) => c.id == widget.transaction.categoryId,
        );
      });
    });
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

    if (response.statusCode == 200 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transaction Updated Successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating transaction"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 30,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Edit Transaction",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Form Card
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Update Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Amount Field
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Color(0xFF6366F1),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type Dropdown
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: InputDecoration(
                        labelText: "Type",
                        prefixIcon: Icon(
                          type == 'expense'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: const Color(0xFF6366F1),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "expense",
                          child: Text("Expense"),
                        ),
                        DropdownMenuItem(
                          value: "income",
                          child: Text("Income"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          type = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<Category>(
                      hint: const Text("Select Category"),
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Category",
                        prefixIcon: const Icon(
                          Icons.category,
                          color: Color(0xFF6366F1),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: "Description",
                        prefixIcon: const Icon(
                          Icons.description,
                          color: Color(0xFF6366F1),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: updateTransaction,
                        child: const Text(
                          "Update Transaction",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
