// lib/services/outfit_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/outfit.dart';

class OutfitService {
  // Base URL for backend API
  final String baseUrl = "http://10.0.2.2:8080/api/outfits";

  /// Add a new outfit for a user
  Future<bool> addOutfit(Outfit outfit, String userEmail) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(outfit.toJson(userEmail)),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Failed to add outfit: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error adding outfit: $e");
    }
    return false;
  }

  /// Fetch all outfits of a specific user
  Future<List<Outfit>> getUserOutfits(String userEmail) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/user/$userEmail"));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => Outfit.fromJson(e)).toList();
      } else {
        print("Failed to fetch outfits: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching outfits: $e");
    }
    return [];
  }
}
