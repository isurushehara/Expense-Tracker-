import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/budget_model.dart';
import 'auth_service.dart';

class BudgetService {

  static const baseUrl = "http://localhost:5000/api";

  static Future<List<Budget>> getBudgets() async {

    String? token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/budgets"),
      headers: {
        "Authorization": token ?? ""
      },
    );

    if(response.statusCode == 200){

      List data = jsonDecode(response.body);

      return data.map((e) => Budget.fromJson(e)).toList();

    }

    return [];

  }

}