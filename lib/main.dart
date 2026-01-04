import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_page.dart'; // change if needed

void main() {
  runApp(const WDApp());
}

class WDApp extends StatelessWidget {
  const WDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WebDevicon',
      theme: ThemeData.dark(),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(), // your next screen
      },
    );
  }
}
