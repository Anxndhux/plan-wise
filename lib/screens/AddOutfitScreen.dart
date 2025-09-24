// lib/screens/add_outfit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/outfit.dart';
import '../services/outfit_service.dart';

class AddOutfitScreen extends StatefulWidget {
  final String userEmail;
  AddOutfitScreen({required this.userEmail});

  @override
  _AddOutfitScreenState createState() => _AddOutfitScreenState();
}

class _AddOutfitScreenState extends State<AddOutfitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _category = 'Casual';
  String _weather = 'Sunny';
  File? _imageFile;
  final _picker = ImagePicker();
  final OutfitService _service = OutfitService();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _saveOutfit() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and select image")),
      );
      return;
    }

    setState(() => _isLoading = true);

    Outfit outfit = Outfit(
      name: _nameController.text,
      category: _category,
      imageUrl: _imageFile!.path,
      weather: _weather,
    );

    bool success = await _service.addOutfit(outfit, widget.userEmail);

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Outfit added!" : "Failed to add")),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Outfit"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Outfit Name"),
                      validator: (value) => value == null || value.isEmpty
                          ? "Enter outfit name"
                          : null,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _category,
                      items: ['Casual', 'Formal', 'Sports', 'Party']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _category = val!),
                      decoration: InputDecoration(labelText: "Category"),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _weather,
                      items: ['Sunny', 'Rainy', 'Cold', 'Hot']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _weather = val!),
                      decoration: InputDecoration(labelText: "Weather"),
                    ),
                    SizedBox(height: 16),
                    _imageFile == null
                        ? ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.image),
                            label: Text("Select Image"),
                          )
                        : Column(
                            children: [
                              Image.file(_imageFile!, height: 150),
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(Icons.edit),
                                label: Text("Change Image"),
                              ),
                            ],
                          ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveOutfit,
                      child: Text("Add Outfit"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
