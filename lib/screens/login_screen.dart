import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'manual_analysis_screen.dart';
import 'home_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading =false;

  Future<void> _login() async {

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage("Please enter username and password");
      return;
    }
setState(() {
  isLoading = true;
});
    final loginResponse = await http.post(
      Uri.parse('http://192.168.142.206:2323/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    print('LOGIN → ${loginResponse.statusCode}');
    print('Body → ${loginResponse.body}');

    if (loginResponse.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      setState(() {
        isLoading =false;
      });
      _showMessage("Login failed. Please check your credentials.");
    }
  }

  void _continueWithoutLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ManualAnalysisScreen(fromLogin: false)),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SignUpScreen()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[700]!, Colors.green[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 60, color: Colors.green[700]),
                      SizedBox(height: 20),
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.green[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          filled: true,
                          fillColor: Colors.green[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: isLoading? Center(child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator())): Text('Login'),
                      ),
                      SizedBox(height: 15),
                      TextButton(
                        onPressed: _navigateToSignUp,
                        child: Text(
                          'Create an Account',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _continueWithoutLogin,
                        child: Text(
                          'Continue without Login',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
