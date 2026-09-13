import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';
import '../utils/asset_path.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _moveToNextScreen();
  }

  Future<void> _moveToNextScreen() async {
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      AuthController.getUserData(),
    ]);

    final isLoggedIn = await AuthController.isUserLoggedIn();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 168,
          height: 168,
          child: Image.asset(AssetPath.splashLogoPng, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
