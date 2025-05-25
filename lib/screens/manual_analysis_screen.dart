import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class ManualAnalysisScreen extends StatefulWidget {
  const ManualAnalysisScreen({Key? key}) : super(key: key);

  @override
  _ManualAnalysisScreenState createState() => _ManualAnalysisScreenState();
}

class _ManualAnalysisScreenState extends State<ManualAnalysisScreen>
    with SingleTickerProviderStateMixin {
  final _nController = TextEditingController();
  final _pController = TextEditingController();
  final _kController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _phController = TextEditingController();
  final _rainfallController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _recommendedCrop;
  bool _isLoading = false;
  bool _showResult = false;
  final _formKey = GlobalKey<FormState>();

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    super.dispose();
  }

  Future<void> _analyzeSoil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _showResult = false;
    });

    try {
      final response = await http
          .post(
            Uri.parse('http://192.168.142.206:5000/predict'),
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
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recommendedCrop = data['recommendedCrop'];
          _showResult = true;
        });
      } else {
        _showMessage(
          'Failed to get prediction. Status code: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      _showMessage('Connection timeout. Please try again.');
    } on Exception catch (e) {
      _showMessage('Error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goHome() {
    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildParameterField({
    required String label,
    required String unit,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
        ],
        decoration: InputDecoration(
          hintText: '$label ($unit)',
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceVariant.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: _goHome, icon: Icon(Icons.arrow_back)),
        title: const Text('Manual Analysis'),
      ),
      extendBodyBehindAppBar: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    'Enter Soil Parameters',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildParameterField(
                    label: 'Nitrogen',
                    unit: 'ppm',
                    controller: _nController,
                    icon: Icons.grass,
                    color: Colors.green,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final val = double.tryParse(value);
                      if (val == null) return 'Invalid number';
                      if (val < 0 || val > 100) return '0-100 ppm range';
                      return null;
                    },
                  ),
                  _buildParameterField(
                    label: 'Phosphorus',
                    unit: 'ppm',
                    controller: _pController,
                    icon: Icons.water_drop,
                    color: Colors.blue,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final val = double.tryParse(value);
                      if (val == null) return 'Invalid number';
                      if (val < 0 || val > 100) return '0-100 ppm range';
                      return null;
                    },
                  ),
                  _buildParameterField(
                    label: 'Potassium',
                    unit: 'ppm',
                    controller: _kController,
                    icon: Icons.science,
                    color: Colors.orange,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final val = double.tryParse(value);
                      if (val == null) return 'Invalid number';
                      if (val < 0 || val > 100) return '0-100 ppm range';
                      return null;
                    },
                  ),
                  _buildParameterField(
                    label: 'Temperature',
                    unit: '°C',
                    controller: _temperatureController,
                    icon: Icons.thermostat,
                    color: Colors.red,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final val = double.tryParse(value);
                      if (val == null) return 'Invalid number';
                      if (val < -20 || val > 50) return '-20 to 50°C range';
                      return null;
                    },
                  ),
                  _buildParameterField(
                    label: 'Humidity',
                    unit: '%',
                    controller: _humidityController,
                    icon: Icons.water,
                    color: Colors.lightBlue,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final val = double.tryParse(value);
                      if (val == null) return 'Invalid number';
                      if (val < 0 || val > 100) return '0-100% range';
                      return null;
                    },
                  ),
                  _buildParameterField(
                    label: 'pH Level',
                    unit: '',
                    controller: _phController,
                    icon: Icons.phishing,
                    color: Colors.purple,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final val = double.tryParse(value);
                      if (val == null) return 'Invalid number';
                      if (val < 0 || val > 14) return '0-14 pH range';
                      return null;
                    },
                  ),
                  _buildParameterField(
                    label: 'Rainfall',
                    unit: 'mm',
                    controller: _rainfallController,
                    icon: Icons.cloudy_snowing,
                    color: Colors.indigo,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final val = double.tryParse(value);
                      if (val == null) return 'Invalid number';
                      if (val < 0 || val > 1000) return '0-1000 mm range';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _analyzeSoil,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'ANALYZE SOIL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_showResult && _recommendedCrop != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.eco, color: Colors.green, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recommended Crop',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                                Text(
                                  _recommendedCrop!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
