import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  final List<String> tips = [
    'Drink at least 2 liters of water today.',
    'Wear sunscreen if going outside.',
    'Perfect day for outdoor yoga!',
    'Carry an umbrella, rain expected tomorrow.',
    'Take a short walk to refresh your mind.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tips & Suggestions')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Icon(Icons.lightbulb, color: Colors.yellow[700]),
              title: Text(tips[index]),
            ),
          );
        },
      ),
    );
  }
}
