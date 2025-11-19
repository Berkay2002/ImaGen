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
            tooltip: 'Undo',
          ),
          IconButton(
            onPressed: () => ref.read(maskProvider.notifier).redo(),
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
          ),
          IconButton(
            onPressed: () => ref.read(maskProvider.notifier).clear(),
            icon: const Icon(Icons.clear),
            tooltip: 'Clear Mask',
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
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('AI is thinking...', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Brush Size'),
                Slider(
                  value: maskState.brushSize,
                  min: 5,
                  max: 50,
                  onChanged: (value) => ref.read(maskProvider.notifier).setBrushSize(value),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                          hintText: 'Enter a prompt (e.g., "Replace with a dog")',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            imageEditingNotifier.editText(
                              imageFile,
                              value,
                              maskState.paths,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: () {
                        if (textEditingController.text.isNotEmpty) {
                          imageEditingNotifier.editText(
                            imageFile,
                            textEditingController.text,
                            maskState.paths,
                          );
                        }
                      },
                      icon: const Icon(Icons.auto_awesome),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
