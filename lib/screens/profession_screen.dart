import 'package:flutter/material.dart';
import '../models/profession.dart';
import '../models/outfit.dart';
import '../services/profession_service.dart';
import '../services/outfit_service.dart';

class ProfessionScreen extends StatefulWidget {
  final String userEmail;
  const ProfessionScreen({required this.userEmail});

  @override
  State<ProfessionScreen> createState() => _ProfessionScreenState();
}

class _ProfessionScreenState extends State<ProfessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String professionType = 'Student';
  bool hasUniform = false;

  List<String> workDays = [];
  List<String> uniformDays = [];
  List<String> allowedCategories = [];
  List<String> offDutyCategories = [];

  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final outfitCategories = ['Casual', 'Formal', 'Traditional', 'Sporty', 'Party'];

  final _service = ProfessionService();
  final _outfitService = OutfitService();

  bool _isExistingProfession = false;
  List<Outfit> _outfits = [];
  String? selectedUniformOutfit;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final outfits = await _outfitService.getUserOutfits(widget.userEmail);
    setState(() {
      _outfits = outfits;
    });

    List<Profession> list = await _service.getProfessions(widget.userEmail);
    if (list.isNotEmpty) {
      final prof = list.first;
      setState(() {
        _isExistingProfession = true;
        _nameController.text = prof.professionName;
        professionType = prof.professionType;
        hasUniform = prof.hasUniform;
        selectedUniformOutfit = prof.uniformOutfit;
        workDays = List.from(prof.workDays);
        uniformDays = List.from(prof.uniformDays);
        allowedCategories = List.from(prof.allowedOutfitCategories);
        offDutyCategories = List.from(prof.offDutyPreferences);
      });
    }
  }

  void _saveProfession() async {
    if (_formKey.currentState!.validate()) {
      final profession = Profession(
        userEmail: widget.userEmail,
        professionName: _nameController.text,
        professionType: professionType,
        hasUniform: hasUniform,
        uniformOutfit: hasUniform ? selectedUniformOutfit : null,
        workDays: workDays,
        uniformDays: hasUniform ? uniformDays : [],
        allowedOutfitCategories: allowedCategories,
        offDutyPreferences: offDutyCategories,
      );

      bool success = await _service.saveProfession(profession);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? (_isExistingProfession ? 'Updated!' : 'Saved!') : 'Failed')),
      );

      if (!_isExistingProfession && success) {
        setState(() => _isExistingProfession = true);
      }
    }
  }

  Widget _buildMultiCheckbox(List<String> items, List<String> selected) {
    return Column(
      children: items.map((item) {
        return CheckboxListTile(
          title: Text(item),
          value: selected.contains(item),
          onChanged: (bool? val) {
            setState(() {
              if (val == true) {
                selected.add(item);
              } else {
                selected.remove(item);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profession Preferences")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Profession Name"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: professionType,
                items: ['Student', 'Working', 'Other'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => setState(() => professionType = value ?? 'Student'),
                decoration: InputDecoration(labelText: "Profession Type"),
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text("Has Uniform?"),
                value: hasUniform,
                onChanged: (val) => setState(() => hasUniform = val),
              ),

              if (hasUniform) ...[
                DropdownButtonFormField<String>(
                  value: selectedUniformOutfit,
                  items: _outfits.map((outfit) {
                    return DropdownMenuItem<String>(
                      value: outfit.name,
                      child: Text(outfit.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUniformOutfit = value;
                    });
                  },
                  decoration: InputDecoration(labelText: "Select Uniform Outfit"),
                  validator: (val) => val == null || val.isEmpty ? "Required" : null,
                ),
                SizedBox(height: 16),
                Text("Uniform Days", style: TextStyle(fontWeight: FontWeight.bold)),
                _buildMultiCheckbox(days, uniformDays),
              ],

              SizedBox(height: 16),
              Text("Work Days", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildMultiCheckbox(days, workDays),

              SizedBox(height: 16),
              Text("Allowed Outfit Categories", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildMultiCheckbox(outfitCategories, allowedCategories),

              SizedBox(height: 16),
              Text("Off-Duty Preferences", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildMultiCheckbox(outfitCategories, offDutyCategories),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfession,
                child: Text(_isExistingProfession ? "Update Profession" : "Save Profession"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
