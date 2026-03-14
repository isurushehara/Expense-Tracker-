import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class CategoryService {

  static const String baseUrl = "http://localhost:5000/api";

  static Future<List<Category>> getCategories() async {

    final response = await http.get(
      Uri.parse("$baseUrl/categories")
    );

    if(response.statusCode == 200){

      List data = jsonDecode(response.body);

      return data.map((e) => Category.fromJson(e)).toList();

    } else {

      return [];

    }

  }

}