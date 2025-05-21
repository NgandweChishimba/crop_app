import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Recommender',
      theme: ThemeData(
        primaryColor: Colors.green[800],
        scaffoldBackgroundColor: Colors.green[50],
        appBarTheme: AppBarTheme(
          color: Colors.green[700],
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            textStyle: TextStyle(fontSize: 18),
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}