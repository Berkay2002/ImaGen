import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

abstract class AiImageEditingService {
  Future<Uint8List> editText(File image, String prompt, List<Path> mask);
}

class MockAiImageEditingService implements AiImageEditingService {
  @override
  Future<Uint8List> editText(File image, String prompt, List<Path> mask) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return a placeholder image
    final ByteData data = await rootBundle.load('assets/placeholder.png');
    return data.buffer.asUint8List();
  }
}
