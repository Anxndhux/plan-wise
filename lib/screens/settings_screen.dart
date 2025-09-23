import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  // Profile variables
  String gender = 'Male';
  String activityPreference = 'Indoor';
  bool isCelsius = true;
  bool notificationsEnabled = true;
  bool weatherAlertsEnabled = true;
  String theme = 'System';
  DateTime? dob;

  File? profileImage;

  // Pick profile image
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  // Pick date of birth
  Future<void> pickDOB() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dob = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : null,
                  child: profileImage == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.white70)
                      : null,
                  backgroundColor: Colors.grey[400],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Profile Info
            Text(
              'Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // Date of Birth
            Row(
              children: [
                Expanded(
                  child: Text(
                    dob != null
                        ? 'DOB: ${dob!.toLocal().toString().split(' ')[0]}'
                        : 'Select DOB',
                  ),
                ),
                ElevatedButton(onPressed: pickDOB, child: Text('Pick DOB')),
              ],
            ),
            SizedBox(height: 10),

            // Gender Dropdown
            Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: gender,
              items: [
                'Male',
                'Female',
                'Other',
              ].map((g) => DropdownMenuItem(child: Text(g), value: g)).toList(),
              onChanged: (value) => setState(() => gender = value!),
            ),
            SizedBox(height: 20),

            // Default City
            Text('Default City', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: 'Enter default city',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Activity Preference
            Text(
              'Activity Preference',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: activityPreference,
              items: [
                'Indoor',
                'Outdoor',
                'Both',
              ].map((a) => DropdownMenuItem(child: Text(a), value: a)).toList(),
              onChanged: (value) => setState(() => activityPreference = value!),
            ),
            SizedBox(height: 20),

            // Temperature Unit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temperature Unit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: isCelsius,
                  onChanged: (value) => setState(() => isCelsius = value),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Notifications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enable Notifications',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: notificationsEnabled,
                  onChanged: (value) =>
                      setState(() => notificationsEnabled = value),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weather Alerts',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: weatherAlertsEnabled,
                  onChanged: (value) =>
                      setState(() => weatherAlertsEnabled = value),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Theme Selection
            Text('App Theme', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: theme,
              items: [
                'Light',
                'Dark',
                'System',
              ].map((t) => DropdownMenuItem(child: Text(t), value: t)).toList(),
              onChanged: (value) => setState(() => theme = value!),
            ),
            SizedBox(height: 30),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save all settings to backend or SharedPreferences
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Settings saved successfully!')),
                  );
                },
                child: Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
