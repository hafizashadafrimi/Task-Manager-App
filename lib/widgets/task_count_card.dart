import 'package:flutter/material.dart';

import '../theme/theme_data.dart';

class TaskCardCount extends StatelessWidget {
  final String title;
  final int count;
  const TaskCardCount({super.key, required this.title, required this.count});

  IconData get _icon => switch (title.toLowerCase()) {
    'new' => Icons.assignment_rounded,
    'progress' || 'in progress' => Icons.timelapse_rounded,
    'completed' => Icons.check_circle_rounded,
    _ => Icons.cancel_rounded,
  };

  Color get _accent => switch (title.toLowerCase()) {
    'new' => const Color(0xFF2563EB),
    'progress' || 'in progress' => const Color(0xFF8B5CF6),
    'completed' => const Color(0xFF16A34A),
    _ => const Color(0xFFEF4444),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _accent, size: 19),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 28,
                height: 1,
                fontWeight: FontWeight.w800,
                color: kText,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
