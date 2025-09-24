// lib/services/outfit_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/outfit.dart';

class OutfitService {
  final String baseUrl = "http://10.0.2.2:8080/api/outfits";

  Future<bool> addOutfit(Outfit outfit, String userEmail) async {
    final response = await http.post(
      Uri.parse("$baseUrl/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(outfit.toJson(userEmail)),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<Outfit>> getUserOutfits(String userEmail) async {
    final response = await http.get(Uri.parse("$baseUrl/user/$userEmail"));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Outfit.fromJson(e)).toList();
    }
    return [];
  }
}
