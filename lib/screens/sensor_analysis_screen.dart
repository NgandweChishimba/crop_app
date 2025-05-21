import 'package:flutter/material.dart';

class SensorAnalysisScreen extends StatefulWidget {
  @override
  _SensorAnalysisScreenState createState() => _SensorAnalysisScreenState();
}

class _SensorAnalysisScreenState extends State<SensorAnalysisScreen> {
  String connectionStatus = 'Checking sensor connection...';
  bool connected = false;

  @override
  void initState() {
    super.initState();
    _connectToSensor();
  }

  Future<void> _connectToSensor() async {
    // Placeholder: Simulate checking connection
    await Future.delayed(Duration(seconds: 2)); // simulate delay

    bool isConnected = await checkESP32Connection();

    if (isConnected) {
      setState(() {
        connectionStatus = 'Sensor connected! Starting analysis...';
        connected = true;
      });
      _startAnalysis();
    } else {
      setState(() {
        connectionStatus = 'Sensor not found. Please check connection.';
        connected = false;
      });
    }
  }

  Future<bool> checkESP32Connection() async {
    // TODO: Replace this with actual Bluetooth or WiFi detection code
    // Simulate successful connection (change to false to test failure)
    return true;
  }

  void _startAnalysis() {
    // TODO: Start reading sensor data & display result
    print('Starting real-time analysis...');
    // You can navigate to a result page or display values here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Real-Time Analysis')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              connected ? Icons.check_circle : Icons.error,
              size: 80,
              color: connected ? Colors.green : Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              connectionStatus,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('Retry Connection'),
              onPressed: _connectToSensor,
            ),
          ],
        ),
      ),
    );
  }
}