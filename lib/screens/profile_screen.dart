import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );
    _fetchUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse('http://192.168.142.206:2323/farmer?user_id=user_id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _error = 'Failed to fetch user data';
          _isLoading = false;
        });
      }
    } on TimeoutException {
      setState(() {
        _error = 'Connection timeout. Please try again.';
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginScreen(),
        transitionsBuilder:
            (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
      (route) => false,
    );
  }

  Widget _buildProfileItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUserData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _fetchUserData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _userData?['full_name'] ?? 'User',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '@${_userData?['username'] ?? 'username'}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildProfileItem(
                                'Email',
                                _userData?['email'] ?? 'N/A',
                                Icons.email_outlined,
                              ),
                              const Divider(height: 1),
                              _buildProfileItem(
                                'Phone',
                                _userData?['phone'] ?? 'N/A',
                                Icons.phone_outlined,
                              ),
                              const Divider(height: 1),
                              _buildProfileItem(
                                'Member Since',
                                'Jan 2023', // Replace with actual date from API
                                Icons.calendar_today_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('LOGOUT'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                            foregroundColor:
                                Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
