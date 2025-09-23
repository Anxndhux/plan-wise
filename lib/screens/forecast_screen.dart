import 'package:flutter/material.dart';

class ForecastScreen extends StatelessWidget {
  final List<Map<String, String>> weeklyForecast = [
    {'day': 'Mon', 'condition': 'Sunny', 'temp': '30°C'},
    {'day': 'Tue', 'condition': 'Cloudy', 'temp': '28°C'},
    {'day': 'Wed', 'condition': 'Rainy', 'temp': '26°C'},
    {'day': 'Thu', 'condition': 'Sunny', 'temp': '31°C'},
    {'day': 'Fri', 'condition': 'Windy', 'temp': '27°C'},
    {'day': 'Sat', 'condition': 'Rainy', 'temp': '25°C'},
    {'day': 'Sun', 'condition': 'Sunny', 'temp': '32°C'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('7-Day Forecast')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: weeklyForecast.length,
        itemBuilder: (context, index) {
          final dayData = weeklyForecast[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Icon(Icons.wb_sunny, color: Colors.orangeAccent),
              title: Text('${dayData['day']} - ${dayData['condition']}'),
              trailing: Text(dayData['temp'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}
