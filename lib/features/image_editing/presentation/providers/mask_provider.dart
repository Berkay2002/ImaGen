import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class MaskState {
  const MaskState({
    required this.paths,
    required this.redoPaths,
    required this.brushSize,
  });

  final List<Path> paths;
  final List<Path> redoPaths;
  final double brushSize;

  MaskState copyWith({
    List<Path>? paths,
    List<Path>? redoPaths,
    double? brushSize,
  }) {
    return MaskState(
      paths: paths ?? this.paths,
      redoPaths: redoPaths ?? this.redoPaths,
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
          redoPaths: [],
          brushSize: 20.0,
        ));

  void addPath(Path path) {
    state = state.copyWith(
      paths: [...state.paths, path],
      redoPaths: [], // Clear redo stack on new action
    );
  }

  void undo() {
    if (state.paths.isNotEmpty) {
      final lastPath = state.paths.last;
      state = state.copyWith(
        paths: state.paths.sublist(0, state.paths.length - 1),
        redoPaths: [...state.redoPaths, lastPath],
      );
    }
  }

  void redo() {
    if (state.redoPaths.isNotEmpty) {
      final lastRedoPath = state.redoPaths.last;
      state = state.copyWith(
        paths: [...state.paths, lastRedoPath],
        redoPaths: state.redoPaths.sublist(0, state.redoPaths.length - 1),
      );
    }
  }

  void clear() {
    // To support undoing a clear, we might need a more complex command pattern,
    // but for now, let's just clear. 
    // If we wanted to undo clear, we'd need to treat "Clear" as a command.
    // For simplicity in this specific request, I'll just clear.
    state = state.copyWith(paths: [], redoPaths: []);
  }

  void setBrushSize(double size) {
    state = state.copyWith(brushSize: size);
  }
}
