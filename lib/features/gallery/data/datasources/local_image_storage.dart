import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localImageStorageProvider = Provider<LocalImageStorage>((ref) {
  return LocalImageStorage();
});

class LocalImageStorage {
  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> saveImage(Uint8List imageBytes) async {
    final path = await _getLocalPath();
    final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('$path/$fileName');
    return file.writeAsBytes(imageBytes);
  }

  Future<List<File>> loadImages() async {
    final path = await _getLocalPath();
    final directory = Directory(path);
    if (!await directory.exists()) {
      return [];
    }
    final files = directory.listSync().whereType<File>().toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync())); // Newest first
    return files;
  }
}