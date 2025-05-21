// lib/extended_manual_analysis_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home_screen.dart';
import 'login_screen.dart';

class ExtendedManualAnalysisScreen extends StatefulWidget {
  final bool fromLogin;

  ExtendedManualAnalysisScreen({required this.fromLogin});

  @override
  _ExtendedManualAnalysisScreenState createState() =>
      _ExtendedManualAnalysisScreenState();
}

class _ExtendedManualAnalysisScreenState
    extends State<ExtendedManualAnalysisScreen> {
  // Soil controllers
  final _nCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  final _kCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _humCtrl = TextEditingController();
  final _phCtrl = TextEditingController();
  final _rainCtrl = TextEditingController();
  // Farm metadata controllers
  final _portionNameCtrl = TextEditingController();
  final _portionDescCtrl = TextEditingController();
  final _farmIdCtrl = TextEditingController();

  String? _prediction;

  Future<void> _submit() async {
    final apiUrl = 'http://192.168.142.206:2323/farm/predict';

    final payload = {
      "nitrogen": double.parse(_nCtrl.text),
      "phosphorus": double.parse(_pCtrl.text),
      "potassium": double.parse(_kCtrl.text),
      "temperature": double.parse(_tempCtrl.text),
      "humidity": double.parse(_humCtrl.text),
      "phValue": double.parse(_phCtrl.text),
      "rainfall": double.parse(_rainCtrl.text),
      "farmPortionName": _portionNameCtrl.text,
      "farmPortionDescription": _portionDescCtrl.text,
      "farm": {
        "id": int.parse(_farmIdCtrl.text),
      }
    };

    try {
      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      print("PREDICT → ${res.statusCode} ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _prediction = data['recommendedCrop'] ?? 'No "recommendedCrop" in response';
        });
      } else {
        _showSnack("Error ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      _showSnack("Network error: $e");
    }
  }

  void _goHome() {
    final dest = widget.fromLogin ? HomeScreen() : LoginScreen();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dest));
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _field(String label, TextEditingController ctl, {bool isNumber = true}) {
    return TextField(
      controller: ctl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extended Manual Analysis'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Soil Parameters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _field('Nitrogen', _nCtrl),
              SizedBox(height: 8),
              _field('Phosphorus', _pCtrl),
              SizedBox(height: 8),
              _field('Potassium', _kCtrl),
              SizedBox(height: 8),
              _field('Temperature (°C)', _tempCtrl),
              SizedBox(height: 8),
              _field('Humidity (%)', _humCtrl),
              SizedBox(height: 8),
              _field('pH Value', _phCtrl),
              SizedBox(height: 8),
              _field('Rainfall (mm)', _rainCtrl),

              SizedBox(height: 16),
              Text('Farm Portion Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _field('Portion Name', _portionNameCtrl, isNumber: false),
              SizedBox(height: 8),
              _field('Portion Description', _portionDescCtrl, isNumber: false),
              SizedBox(height: 8),
              _field('Farm ID', _farmIdCtrl),

              SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text('Get Prediction')),

              if (_prediction != null) ...[
                SizedBox(height: 20),
                Text(_prediction!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
              ],
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _goHome,
        tooltip: 'Home',
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.home),
      ),
    );
  }
}
