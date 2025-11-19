import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/features/image_editing/presentation/providers/image_editing_provider.dart';
import 'package:my_app/features/image_editing/presentation/providers/mask_provider.dart';
import 'package:my_app/features/image_editing/presentation/widgets/masking_canvas.dart';

class ImageEditingPage extends ConsumerWidget {
  const ImageEditingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFile = ModalRoute.of(context)!.settings.arguments as File;
    final maskState = ref.watch(maskProvider);
    final imageEditingState = ref.watch(imageEditingProvider);
    final imageEditingNotifier = ref.read(imageEditingProvider.notifier);
    final textEditingController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Image'),
        actions: [
          IconButton(
            onPressed: () => ref.read(maskProvider.notifier).undo(),
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            onPressed: () => ref.read(maskProvider.notifier).clear(),
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (imageEditingState.status == ImageEditingStatus.success)
                  Image.memory(imageEditingState.result!)
                else
                  Image.file(imageFile),
                if (imageEditingState.status != ImageEditingStatus.success)
                  const MaskingCanvas(),
                if (imageEditingState.status == ImageEditingStatus.loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('Brush Size'),
                Slider(
                  value: maskState.brushSize,
                  min: 5,
                  max: 50,
                  onChanged: (value) => ref.read(maskProvider.notifier).setBrushSize(value),
                ),
                TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Enter a prompt (e.g., "Replace with a dog")',
                  ),
                  onSubmitted: (value) {
                    imageEditingNotifier.editText(
                      imageFile,
                      value,
                      maskState.paths,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
