import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Assume a token or user ID is stored after login (e.g., in SharedPreferences or Provider)
      // Replace 'user_id' with actual user ID or token from login
      final response = await http.get(
        Uri.parse('http://192.168.142.206:2323/farmer?user_id=user_id'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication header if required, e.g., 'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch user data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 20),
            Card(

              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${_userData?['email'] ?? "N/A"}'),
                    Text('Full Name: ${_userData?['full_name'] ?? "N/A"}'),
                    Text('Phone: ${_userData?['phone'] ?? "N/A"}'),
                    Text('Username: ${_userData?['username'] ?? "N/A"}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}