import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Composites a red mask onto an image for semantic inpainting.
///
/// Takes an original image file, a list of paths representing the mask area (in screen coordinates),
/// screen dimensions, and brush size. Returns a PNG image with the red mask overlay applied.
///
/// The paths are transformed from screen coordinates to image coordinates accounting for
/// how the image is displayed with BoxFit.contain.
///
/// If [baseImageBytes] is provided, it will be used instead of reading from the original file.
/// This allows applying masks to previously edited images.
Future<Uint8List> compositeMaskOntoImage(
  File originalImage,
  List<ui.Path> paths,
  double brushSize, {
  Size? screenSize,
  Uint8List? baseImageBytes,
}) async {
  // Load the image - use baseImageBytes if provided, otherwise read from file
  final imageBytes = baseImageBytes ?? await originalImage.readAsBytes();
  final codec = await ui.instantiateImageCodec(imageBytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final imageWidth = image.width.toDouble();
  final imageHeight = image.height.toDouble();

  // Calculate the scale factor if screen size is provided
  double scaleX = 1.0;
  double scaleY = 1.0;
  double offsetX = 0.0;
  double offsetY = 0.0;

  if (screenSize != null) {
    // Calculate how the image is displayed with BoxFit.contain
    final imageAspect = imageWidth / imageHeight;
    final screenAspect = screenSize.width / screenSize.height;

    if (imageAspect > screenAspect) {
      // Image is wider - fits to width
      final displayHeight = screenSize.width / imageAspect;
      scaleX = imageWidth / screenSize.width;
      scaleY = imageHeight / displayHeight;
      offsetY = (screenSize.height - displayHeight) / 2;
    } else {
      // Image is taller - fits to height
      final displayWidth = screenSize.height * imageAspect;
      scaleX = imageWidth / displayWidth;
      scaleY = imageHeight / screenSize.height;
      offsetX = (screenSize.width - displayWidth) / 2;
    }
  }

  // Create a canvas to draw on
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Draw the original image
  canvas.drawImage(image, Offset.zero, Paint());

  // Draw the red mask with higher opacity for better AI recognition
  final maskPaint = Paint()
    ..color = Colors.red.withOpacity(0.8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = brushSize * scaleX // Scale brush size to image coordinates
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // Transform and draw each path
  for (final path in paths) {
    final matrix = Matrix4.identity()
      ..translate(-offsetX, -offsetY)
      ..scale(scaleX, scaleY);

    final transformedPath = path.transform(matrix.storage);
    canvas.drawPath(transformedPath, maskPaint);
  }

  // Convert to image
  final picture = recorder.endRecording();
  final compositeImage = await picture.toImage(
    image.width,
    image.height,
  );

  // Convert to PNG bytes
  final byteData = await compositeImage.toByteData(
    format: ui.ImageByteFormat.png,
  );

  // Clean up
  image.dispose();
  compositeImage.dispose();

  return byteData!.buffer.asUint8List();
}

/// Resizes an image if it exceeds the maximum dimension.
///
/// Ensures the image stays under size limits for API calls while maintaining
/// aspect ratio. Returns the resized image bytes.
Future<Uint8List> resizeImageIfNeeded(
  Uint8List imageBytes, {
  int maxDimension = 2048,
}) async {
  final codec = await ui.instantiateImageCodec(imageBytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  // Check if resizing is needed
  if (image.width <= maxDimension && image.height <= maxDimension) {
    image.dispose();
    return imageBytes;
  }

  // Calculate new dimensions maintaining aspect ratio
  double scale;
  if (image.width > image.height) {
    scale = maxDimension / image.width;
  } else {
    scale = maxDimension / image.height;
  }

  final newWidth = (image.width * scale).round();
  final newHeight = (image.height * scale).round();

  // Create a recorder and canvas for resizing
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Draw the resized image
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
    Paint(),
  );

  // Convert to image
  final picture = recorder.endRecording();
  final resizedImage = await picture.toImage(newWidth, newHeight);

  // Convert to PNG bytes
  final byteData = await resizedImage.toByteData(
    format: ui.ImageByteFormat.png,
  );

  // Clean up
  image.dispose();
  resizedImage.dispose();

  return byteData!.buffer.asUint8List();
}
