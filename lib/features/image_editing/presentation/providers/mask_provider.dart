import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class MaskState {
  const MaskState({
    required this.paths,
    required this.redoPaths,
    required this.brushSize,
    required this.currentPath,
  });

  final List<Path> paths;
  final List<Path> redoPaths;
  final double brushSize;
  final Path? currentPath;

  MaskState copyWith({
    List<Path>? paths,
    List<Path>? redoPaths,
    double? brushSize,
    Path? currentPath,
    bool clearCurrentPath = false,
  }) {
    return MaskState(
      paths: paths ?? this.paths,
      redoPaths: redoPaths ?? this.redoPaths,
      brushSize: brushSize ?? this.brushSize,
      currentPath: clearCurrentPath ? null : (currentPath ?? this.currentPath),
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
          currentPath: null,
        ));

  void startPath(Offset position) {
    final path = Path()..moveTo(position.dx, position.dy);
    state = state.copyWith(currentPath: path);
  }

  void updatePath(Offset position) {
    if (state.currentPath != null) {
      final path = Path.from(state.currentPath!)
        ..lineTo(position.dx, position.dy);
      state = state.copyWith(currentPath: path);
    }
  }

  void endPath() {
    if (state.currentPath != null) {
      state = state.copyWith(
        paths: [...state.paths, state.currentPath!],
        redoPaths: [], // Clear redo stack on new action
        clearCurrentPath: true,
      );
    }
  }

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
    state = state.copyWith(paths: [], redoPaths: []);
  }

  void setBrushSize(double size) {
    state = state.copyWith(brushSize: size);
  }
}