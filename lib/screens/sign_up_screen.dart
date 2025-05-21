import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register() async {
    final response = await http.post(
      Uri.parse('http://192.168.142.206:2323/farmer'), // Replace with your endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim(),
        "full_name": _fullNameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "password": _passwordController.text.trim(),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      Navigator.pop(context); // Go back to login screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created successfully. Please login.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed. Please try again.")),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildTextField("Username", _usernameController),
            SizedBox(height: 15),
            _buildTextField("Email", _emailController),
            SizedBox(height: 15),
            _buildTextField("Full Name", _fullNameController),
            SizedBox(height: 15),
            _buildTextField("Phone", _phoneController),
            SizedBox(height: 15),
            _buildTextField("Password", _passwordController, isPassword: true),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _register,
              child: Text("Register"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
