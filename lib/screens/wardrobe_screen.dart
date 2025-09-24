import 'package:flutter/material.dart';

class WardrobeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> outfits = ['Casual', 'Formal', 'Sport', 'Party'];

    return Scaffold(
      appBar: AppBar(title: Text('Wardrobe Manager')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your wardrobe categories:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ...outfits.map(
              (outfit) => Card(
                child: ListTile(
                  title: Text(outfit),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Later: add/edit outfit
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
