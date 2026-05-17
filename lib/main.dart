import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCP RH',
      debugShowCheckedModeBanner: false,
      theme: OcpTheme.theme,
      home: _isLoggedIn
          ? const DashboardScreen()
          : LoginScreen(onLogin: () => setState(() => _isLoggedIn = true)),
    );
  }
}
