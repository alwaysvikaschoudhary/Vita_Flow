import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const VitaFlowApp());
}

class VitaFlowApp extends StatelessWidget {
  const VitaFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
