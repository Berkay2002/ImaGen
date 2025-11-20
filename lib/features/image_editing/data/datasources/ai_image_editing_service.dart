import 'dart:io';
import 'dart:ui'; // For Path

import 'package:flutter/services.dart'; // For rootBundle

abstract class AiImageEditingService {
  Future<Uint8List> editText(
    File image,
    String prompt,
    List<Path> mask,
    double brushSize,
    Size screenSize, {
    Uint8List? currentEditedImage,
  });
}

class MockAiImageEditingService implements AiImageEditingService {
  @override
  Future<Uint8List> editText(
    File image,
    String prompt,
    List<Path> mask,
    double brushSize,
    Size screenSize, {
    Uint8List? currentEditedImage,
  }) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return a placeholder image
    // Ensure you have 'assets/placeholder.png' in your pubspec.yaml and folder
    try {
      final ByteData data = await rootBundle.load('assets/placeholder.png');
      return data.buffer.asUint8List();
    } catch (e) {
      // Fallback if asset is missing
      return Uint8List(0);
    }
  }
}
