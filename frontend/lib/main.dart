import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_init_stub.dart' if (dart.library.html) 'web_init_web.dart';
import 'screens/splash_screen.dart';

void main() {
  if (kIsWeb) {
    injectGoogleMapsScript();
  }
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
