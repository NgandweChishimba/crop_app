// sensor_data.dart
class SensorData {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double temperature;
  final double humidity;
  final double ph;
  final double rainfall;

  SensorData({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.rainfall,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      nitrogen: json['N'].toDouble(),
      phosphorus: json['P'].toDouble(),
      potassium: json['K'].toDouble(),
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      ph: json['ph'].toDouble(),
      rainfall: json['rainfall'].toDouble(),
    );
  }
  double getValueByTitle(String title) {
    switch (title) {
      case 'NITROGEN':
        return nitrogen;
      case 'PHOSPHORUS':
        return phosphorus;
      case 'POTASSIUM':
        return potassium;
      case 'TEMPERATURE':
        return temperature;
      case 'HUMIDITY':
        return humidity;
      case 'pH LEVEL':
        return ph;
      case 'RAINFALL':
        return rainfall;
      default:
        return 0.0;
    }
  }
}