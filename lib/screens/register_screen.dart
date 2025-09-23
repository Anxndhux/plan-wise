import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final genderController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final authService = AuthService();

  void registerUser() async {
    final message = await authService.registerUser(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      gender: genderController.text,
      dob: dobController.text,
      phone: phoneController.text,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: genderController,
                  decoration: InputDecoration(labelText: 'Gender'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: dobController,
                  decoration: InputDecoration(labelText: 'DOB (YYYY-MM-DD)'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: registerUser,
                  child: Text('Register'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
