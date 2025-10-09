// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey =
      '9e719067f72a4af5ad09b724945dfa2c'; // Replace with your key

  /// Fetch current weather by city
  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'temperature': '${data['main']['temp']}°C',
          'condition': data['weather'][0]['main'],
          'city': data['name'],
        };
      } else {
        return {'temperature': '--', 'condition': 'Unknown', 'city': city};
      }
    } catch (e) {
      return {'temperature': '--', 'condition': 'Error', 'city': city};
    }
  }

  /// ✅ Fetch 5-day forecast using FREE OpenWeather API (5-day / 3-hour)
  Future<List<Map<String, dynamic>>> get5DayForecast(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
    );

    try {
      final response = await http.get(url);
      print('Status code: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['list'];

        // Pick one forecast per day at 12:00 PM
        final Map<String, Map<String, dynamic>> dailyForecast = {};
        for (var item in list) {
          final dtTxt = item['dt_txt']; // Example: "2025-10-09 12:00:00"
          if (dtTxt.contains('12:00:00')) {
            final date = dtTxt.split(' ')[0];
            dailyForecast[date] = {
              'dt': DateTime.parse(dtTxt).millisecondsSinceEpoch ~/ 1000,
              'temp': '${item['main']['temp']}°C',
              'condition': item['weather'][0]['main'],
            };
          }
        }

        return dailyForecast.values.toList().take(5).toList();
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch forecast: $e');
    }
  }
}
