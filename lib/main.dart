import 'package:flutter/material.dart';
import 'package:task_manager_app_assignment/screens/splash_screen.dart';
import 'package:task_manager_app_assignment/theme/theme_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: themeData(),
    home: const SplashScreen(),
  );
}
