import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/notebook_illustration.dart';
import '../widgets/primary_button.dart';
import 'notes_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NotesHomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: _Bubble(size: 180, opacity: 0.12),
            ),
            Positioned(
              top: 120,
              left: -70,
              child: _Bubble(size: 140, opacity: 0.1),
            ),
            Positioned(
              bottom: 180,
              right: -30,
              child: _Bubble(size: 100, opacity: 0.08),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 36),
                        const Text(
                          'Notesy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        const NotebookIllustration(size: 300),
                        const SizedBox(height: 36),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 28,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cyan,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyan.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'All your ideas',
                                style: TextStyle(
                                  color: AppColors.dark,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'in ',
                                    style: TextStyle(
                                      color: AppColors.dark,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Text(
                                      'one place',
                                      style: TextStyle(
                                        color: AppColors.dark,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        PrimaryButton(
                          label: 'Get Started',
                          onPressed: _goToHome,
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
