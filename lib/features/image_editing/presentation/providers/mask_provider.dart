import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class MaskState {
  const MaskState({
    required this.paths,
    required this.brushSize,
  });

  final List<Path> paths;
  final double brushSize;

  MaskState copyWith({
    List<Path>? paths,
    double? brushSize,
  }) {
    return MaskState(
      paths: paths ?? this.paths,
      brushSize: brushSize ?? this.brushSize,
    );
  }
}

final maskProvider = StateNotifierProvider<MaskNotifier, MaskState>((ref) {
  return MaskNotifier();
});

class MaskNotifier extends StateNotifier<MaskState> {
  MaskNotifier()
      : super(const MaskState(
          paths: [],
          brushSize: 20.0,
        ));

  void addPath(Path path) {
    state = state.copyWith(paths: [...state.paths, path]);
  }

  void undo() {
    if (state.paths.isNotEmpty) {
      state = state.copyWith(paths: state.paths.sublist(0, state.paths.length - 1));
    }
  }

  void clear() {
    state = state.copyWith(paths: []);
  }

  void setBrushSize(double size) {
    state = state.copyWith(brushSize: size);
  }
}
