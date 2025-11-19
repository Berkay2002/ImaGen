import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart' hide Path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/features/image_editing/data/datasources/ai_image_editing_service.dart';

enum ImageEditingStatus {
  initial,
  loading,
  success,
  failure,
}

@immutable
class ImageEditingState {
  const ImageEditingState({
    this.status = ImageEditingStatus.initial,
    this.result,
    this.error,
  });

  final ImageEditingStatus status;
  final Uint8List? result;
  final String? error;

  ImageEditingState copyWith({
    ImageEditingStatus? status,
    Uint8List? result,
    String? error,
  }) {
    return ImageEditingState(
      status: status ?? this.status,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

final imageEditingServiceProvider = Provider<AiImageEditingService>((ref) {
  return MockAiImageEditingService();
});

final imageEditingProvider =
    StateNotifierProvider<ImageEditingNotifier, ImageEditingState>((ref) {
  return ImageEditingNotifier(ref.watch(imageEditingServiceProvider));
});

class ImageEditingNotifier extends StateNotifier<ImageEditingState> {
  ImageEditingNotifier(this._service) : super(const ImageEditingState());

  final AiImageEditingService _service;

  Future<void> editText(File image, String prompt, List<Path> mask) async {
    state = state.copyWith(status: ImageEditingStatus.loading);
    try {
      final result = await _service.editText(image, prompt, mask);
      state = state.copyWith(status: ImageEditingStatus.success, result: result);
    } catch (e) {
      state = state.copyWith(status: ImageEditingStatus.failure, error: e.toString());
    }
  }
}
