import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/comic.dart';

class ApiService {
  // static const String baseUrl = 'http://localhost:5142/api';
  static const String baseUrl = 'https://comicoapi-production.up.railway.app/api';
  // comicoapi-production.up.railway.app


  static Future<List<Comic>> getComics() async {
    final response = await http.get(Uri.parse('$baseUrl/comics'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Comic.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<String>> getBanners() async {
    final response = await http.get(Uri.parse('$baseUrl/banners'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  static Future<List<Comic>> searchComics(String q) async {
    if (q.length < 3) return [];
    final response = await http.get(
      Uri.parse('$baseUrl/comics/search?q=$q'),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Comic.fromJson(e)).toList();
    }
    return [];
  }
}