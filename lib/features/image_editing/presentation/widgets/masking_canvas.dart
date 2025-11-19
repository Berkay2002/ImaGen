import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/features/image_editing/presentation/providers/mask_provider.dart';

class MaskingCanvas extends ConsumerWidget {
  const MaskingCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maskState = ref.watch(maskProvider);
    final notifier = ref.read(maskProvider.notifier);

    return GestureDetector(
      onPanStart: (details) {
        notifier.startPath(details.localPosition);
      },
      onPanUpdate: (details) {
        notifier.updatePath(details.localPosition);
      },
      onPanEnd: (details) {
        notifier.endPath();
      },
      child: CustomPaint(
        painter: MaskPainter(
          paths: maskState.paths,
          currentPath: maskState.currentPath,
          brushSize: maskState.brushSize,
        ),
        child: Container(),
      ),
    );
  }
}

class MaskPainter extends CustomPainter {
  MaskPainter({
    required this.paths,
    required this.currentPath,
    required this.brushSize,
  });

  final List<Path> paths;
  final Path? currentPath;
  final double brushSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = brushSize
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw all completed paths
    for (final path in paths) {
      canvas.drawPath(path, paint);
    }

    // Draw the current path being drawn
    if (currentPath != null) {
      canvas.drawPath(currentPath!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
