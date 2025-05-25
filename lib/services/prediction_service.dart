import 'dart:math';

import 'package:crop_app/models/sensor_data.dart';

class PredictionService {
  Future<String> getCropRecommendation(SensorData data) async {
    // Simulate AI prediction with mock logic
    await Future.delayed(const Duration(seconds: 1));
    final crops = ['Wheat', 'Rice', 'Maize', 'Sugarcane', 'Cotton', 'Tomato'];
    return crops[Random().nextInt(crops.length)];
  }
}