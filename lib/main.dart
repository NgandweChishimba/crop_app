import 'package:crop_app/screens/home_screen.dart';
import 'package:crop_app/screens/login_screen.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: AppBarTheme(
          color: Colors.grey.shade100
        ),
        cardTheme: CardTheme(
          elevation: 0.2,
          margin: EdgeInsets.zero,
          color: Colors.white,
        )
      ),
      home: SplashScreen(),
    );
  }
}