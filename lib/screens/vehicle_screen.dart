import 'package:flutter/material.dart';

class VehicleScreen extends StatefulWidget {
  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  String? selectedVehicle;
  final List<String> vehicles = [
    'Car',
    'Bike',
    'Scooter',
    'Bicycle',
    'Public Transport',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Preferences'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Select your preferred vehicle:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...vehicles.map(
              (vehicle) => RadioListTile<String>(
                title: Text(vehicle),
                value: vehicle,
                groupValue: selectedVehicle,
                onChanged: (value) {
                  setState(() {
                    selectedVehicle = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedVehicle == null
                  ? null
                  : () {
                      Navigator.pop(context, selectedVehicle);
                    },
              child: Text('Save Preference'),
            ),
          ],
        ),
      ),
    );
  }
}
