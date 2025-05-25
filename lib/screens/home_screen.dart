// dashboard_screen.dart
import 'dart:async';
import 'package:crop_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:crop_app/models/sensor_data.dart';
import 'package:crop_app/services/prediction_service.dart';
import 'package:crop_app/services/sensor_service.dart';

import 'manual_analysis_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SensorService _sensorService = SensorService();
  final PredictionService _predictionService = PredictionService();
  late SensorData _sensorData;
  late Timer timer;
  String _prediction = '';
  bool _isLoading = false;
  bool _hasInitialData = false;

  @override
  void initState() {
    super.initState();
    _sensorData = SensorData(
      nitrogen: 0,
      phosphorus: 0,
      potassium: 0,
      temperature: 0,
      humidity: 0,
      ph: 0,
      rainfall: 0,
    );
    _loadData();
    timer = Timer.periodic(const Duration(seconds: 3), (timer) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _sensorService.getSensorData();
    setState(() {
      _sensorData = data;
      _isLoading = false;
      _hasInitialData = true;
    });
  }

  Future<void> _predictCrop() async {
    setState(() => _isLoading = true);
    final prediction = await _predictionService.getCropRecommendation(
      _sensorData,
    );
    setState(() {
      _prediction = prediction;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap:
              () => {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ProfileScreen(),
                    transitionsBuilder:
                        (_, a, __, c) => SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(a),
                          child: c,
                        ),
                  ),
                ),
              },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(child: Icon(Icons.person)),
          ),
        ),
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child:
                  _isLoading && !_hasInitialData
                      ? _buildShimmerLoader()
                      : _buildSensorGrid(),
            ),
            const SizedBox(height: 20),
            _buildPredictionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorGrid() {
    final sensorCards = [
      _buildSensorCard(
        'NITROGEN',
        '${_sensorData.nitrogen.toStringAsFixed(1)} ppm',
        Icons.eco,
        Colors.green,
      ),
      _buildSensorCard(
        'PHOSPHORUS',
        '${_sensorData.phosphorus.toStringAsFixed(1)} ppm',
        Icons.water_drop,
        Colors.blue,
      ),
      _buildSensorCard(
        'POTASSIUM',
        '${_sensorData.potassium.toStringAsFixed(1)} ppm',
        Icons.science,
        Colors.orange,
      ),
      _buildSensorCard(
        'TEMPERATURE',
        '${_sensorData.temperature.toStringAsFixed(1)}°C',
        Icons.thermostat,
        Colors.red,
      ),
      _buildSensorCard(
        'HUMIDITY',
        '${_sensorData.humidity.toStringAsFixed(1)}%',
        Icons.water,
        Colors.lightBlue,
      ),
      _buildSensorCard(
        'pH LEVEL',
        _sensorData.ph.toStringAsFixed(1),
        Icons.phishing,
        Colors.purple,
      ),
      _buildSensorCard(
        'RAINFALL',
        '${_sensorData.rainfall.toStringAsFixed(1)} mm',
        Icons.cloudy_snowing,
        Colors.indigo,
      ),
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.2),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (_, __, ___) => ManualAnalysisScreen(),
              transitionsBuilder:
                  (_, a, __, c) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(a),
                    child: c,
                  ),
            ),
          );
        },
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_graph, size: 40, color: Colors.deepPurple),
            Text(
              "Manual Analysis",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.7,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: sensorCards,
    );
  }

  Widget _buildSensorCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: _getProgressValue(title),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  double _getProgressValue(String title) {
    final value = _sensorData.getValueByTitle(title);
    switch (title) {
      case 'pH LEVEL':
        return (value - 3) / 7; // pH range 3-10
      case 'TEMPERATURE':
        return (value - 20) / 20; // 20-40°C
      case 'HUMIDITY':
        return value / 100;
      default:
        return value / 300; // For other values assuming max 300
    }
  }

  Widget _buildPredictionSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended Crop',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.spa, color: Theme.of(context).colorScheme.primary),
              ],
            ),
            const SizedBox(height: 15),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  _prediction.isEmpty
                      ? Text(
                        'Press button to analyze',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      )
                      : Text(
                        _prediction,
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text('Analyze Soil & Climate'),
              onPressed: _predictCrop,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: List.generate(
        7,
        (index) => Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
