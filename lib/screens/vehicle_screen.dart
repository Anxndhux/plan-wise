import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

class VehicleScreen extends StatefulWidget {
  final String userEmail;
  VehicleScreen({required this.userEmail});

  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  List<String> vehicles = ['Car', 'Two wheeler'];
  List<String> selectedVehicles = [];
  bool isLoading = false;
  final VehicleService _service = VehicleService();

  @override
  void initState() {
    super.initState();
    _loadUserVehicles();
  }

  void _loadUserVehicles() async {
    VehiclePreference? pref = await _service.getVehicle(widget.userEmail);
    if (pref != null) {
      setState(() {
        selectedVehicles = pref.vehicleTypes;
      });
    }
  }

  void _saveVehicles() async {
    if (selectedVehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Select at least one vehicle")));
      return;
    }

    setState(() => isLoading = true);
    VehiclePreference pref = VehiclePreference(userEmail: widget.userEmail, vehicleTypes: selectedVehicles);
    bool success = await _service.saveVehicle(pref);
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Saved successfully!" : "Failed to save")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vehicle Preferences"), backgroundColor: Colors.blueAccent),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Select your preferred vehicles:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  ...vehicles.map((v) => CheckboxListTile(
                        title: Text(v),
                        value: selectedVehicles.contains(v),
                        onChanged: (val) {
                          setState(() {
                            if (val == true)
                              selectedVehicles.add(v);
                            else
                              selectedVehicles.remove(v);
                          });
                        },
                      )),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveVehicles,
                    child: Text("Save Preferences"),
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                  ),
                ],
              ),
            ),
    );
  }
}
