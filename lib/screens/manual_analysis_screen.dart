import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home_screen.dart';
import 'login_screen.dart';

class ManualAnalysisScreen extends StatefulWidget {
  final bool fromLogin;

  ManualAnalysisScreen({required this.fromLogin});

  @override
  _ManualAnalysisScreenState createState() => _ManualAnalysisScreenState();
}

class _ManualAnalysisScreenState extends State<ManualAnalysisScreen> {
  final _nController = TextEditingController();
  final _pController = TextEditingController();
  final _kController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _phController = TextEditingController();
  final _rainfallController = TextEditingController();

  String? _recommendedCrop;

  void _analyzeSoil() async {
    final String apiUrl = 'http://192.168.142.206:5000/predict'; // Use your machine's IP

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'N': double.parse(_nController.text),
          'P': double.parse(_pController.text),
          'K': double.parse(_kController.text),
          'temperature': double.parse(_temperatureController.text),
          'humidity': double.parse(_humidityController.text),
          'ph': double.parse(_phController.text),
          'rainfall': double.parse(_rainfallController.text),
        }),
      );

      // 🔍 Debugging print statements
      print('POST to $apiUrl → status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recommendedCrop = 'Recommended Crop: ${data['recommendedCrop']} 🌱';
        });
      } else {
        _showMessage(
            'Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error occurred: ${e.toString()}');
    }
  }

  void _goHome() {
    if (widget.fromLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manual Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter Soil Parameters:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildTextField('Nitrogen (N)', _nController),
              SizedBox(height: 10),
              _buildTextField('Phosphorus (P)', _pController),
              SizedBox(height: 10),
              _buildTextField('Potassium (K)', _kController),
              SizedBox(height: 10),
              _buildTextField('Temperature (°C)', _temperatureController),
              SizedBox(height: 10),
              _buildTextField('Humidity (%)', _humidityController),
              SizedBox(height: 10),
              _buildTextField('pH', _phController),
              SizedBox(height: 10),
              _buildTextField('Rainfall (mm)', _rainfallController),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _analyzeSoil,
                  child: Text('Analyze Soil'),
                ),
              ),
              SizedBox(height: 30),
              if (_recommendedCrop != null)
                Center(
                  child: Text(
                    _recommendedCrop!,
                    style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700]),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _goHome,
        tooltip: 'Go Home',
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.home),
      ),
    );
  }
}
