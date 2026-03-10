import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/chart_model.dart';
import 'auth_service.dart';

class ChartService {
  static const baseUrl = "http://localhost:5000/api";

  static Future<List<ChartData>> getExpenseChart() async {
    String? token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/charts/expense-category"),
      headers: {"Authorization": token ?? ""},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data.map((e) => ChartData.fromJson(e)).toList();
    }

    return [];
  }
}
