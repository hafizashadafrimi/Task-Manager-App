import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NotebookIllustration extends StatelessWidget {
  const NotebookIllustration({super.key, this.size = 220});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.78,
            height: size * 0.72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 18),
                ...List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 28, right: 28, bottom: 28),
                  child: CustomPaint(
                    size: const Size(double.infinity, 36),
                    painter: _ScribblePainter(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: size * 0.08,
            top: size * 0.06,
            child: Column(
              children: List.generate(
                6,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: size * 0.06,
            top: size * 0.18,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 28,
                height: size * 0.55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.cyan, AppColors.cyanDark],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyan.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScribblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.dark
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.1, size.width * 0.45, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.85, size.width, size.height * 0.35);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
