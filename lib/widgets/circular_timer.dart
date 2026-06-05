import 'package:flutter/material.dart';

class CircularTimer extends StatelessWidget {
  const CircularTimer({
    super.key,
    required this.progress,
    required this.remainingSeconds,
  });

  final double progress;
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return SizedBox.square(
      dimension: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
              strokeWidth: 18,
              strokeCap: StrokeCap.round,
              backgroundColor: const Color(0xFFE8EDF8),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$minutes:$seconds', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('quete de focus', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
