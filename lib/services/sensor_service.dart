import 'dart:math';

import 'package:crop_app/models/sensor_data.dart';

class SensorService {
  Future<SensorData> getSensorData() async {
    // Simulate sensor data with random values
    await Future.delayed(const Duration(seconds: 1));
    return SensorData(
      nitrogen: Random().nextDouble() * 100,
      phosphorus: Random().nextDouble() * 100,
      potassium: Random().nextDouble() * 100,
      temperature: 20 + Random().nextDouble() * 20, // 20-40°C
      humidity: 30 + Random().nextDouble() * 70, // 30-100%
      ph: 3 + Random().nextDouble() * 7, // 3-10 pH
      rainfall: Random().nextDouble() * 300, // 0-300mm
    );
  }
}