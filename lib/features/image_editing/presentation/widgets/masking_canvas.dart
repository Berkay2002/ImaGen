
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
      onPanUpdate: (details) {
        final path = Path()
          ..addOval(Rect.fromCircle(
            center: details.localPosition,
            radius: maskState.brushSize / 2,
          ));
        notifier.addPath(path);
      },
      child: CustomPaint(
        painter: MaskPainter(paths: maskState.paths),
        child: Container(),
      ),
    );
  }
}

class MaskPainter extends CustomPainter {
  MaskPainter({required this.paths});

  final List<Path> paths;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
