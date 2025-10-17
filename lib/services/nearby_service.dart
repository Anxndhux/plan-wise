// lib/services/nearby_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NearbyService {
  final String apiKey = 'AIzaSyBWyKyGkm1iSWAjZ9o9gos-gvqBiR884Ss';

  /// Fetches nearby places for a given location and type
  Future<List<Map<String, dynamic>>> getNearbyPlaces(
    double lat,
    double lon,
    String type,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lon&radius=1500&type=$type&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;
        return results.map((place) {
          return {
            'name': place['name'],
            'address': place['vicinity'],
            'rating': place['rating'] ?? 0,
            'icon': place['icon'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch nearby places: $e');
    }
  }
}
