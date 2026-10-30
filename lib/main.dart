import 'package:flutter/material.dart';
import 'package:sv_vehicle_license_plate_detection/Pages/SplashScreen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'schlyer'),
      home: const SplashScreen(),
    );
  }
}
