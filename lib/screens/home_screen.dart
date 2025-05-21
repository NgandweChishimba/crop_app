import 'package:flutter/material.dart';
import 'sensor_analysis_screen.dart';
import 'manual_analysis_screen.dart';
import 'profile_screen.dart'; // ✅ import profile screen

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Recommender'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.sensors),
              label: Text('Analyze with Sensors'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SensorAnalysisScreen()),
                );
              },

            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.edit),
              label: Text('Manual Analysis'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManualAnalysisScreen(fromLogin: true)),
                );
              },

            ),
          ],
        ),
      ),
    );
  }
}