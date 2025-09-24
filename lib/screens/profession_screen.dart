import 'package:flutter/material.dart';

class ProfessionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> professions = [
      'Student',
      'Engineer',
      'Doctor',
      'Artist',
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Select Your Profession')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose your profession:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ...professions.map(
              (prof) => Card(
                child: ListTile(
                  title: Text(prof),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Later: save profession
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
