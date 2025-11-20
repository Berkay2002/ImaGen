import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/features/image_editing/presentation/providers/image_editing_provider.dart';
import 'package:my_app/features/image_editing/presentation/providers/mask_provider.dart';
import 'package:my_app/features/gallery/data/datasources/local_image_storage.dart';
import 'package:my_app/features/image_editing/domain/services/prompt_suggestion_service.dart';
import 'package:my_app/features/image_editing/presentation/widgets/masking_canvas.dart';

class ImageEditingPage extends ConsumerStatefulWidget {
  final File imageFile;

  const ImageEditingPage({super.key, required this.imageFile});

  @override
  ConsumerState<ImageEditingPage> createState() => _ImageEditingPageState();
}

class _ImageEditingPageState extends ConsumerState<ImageEditingPage> {
  final LocalImageStorage _localStorage = LocalImageStorage();
  final PromptSuggestionService _promptService = PromptSuggestionService();
  final TextEditingController _textEditingController = TextEditingController();
  final ValueNotifier<bool> _isResizingBrush = ValueNotifier(false);
  Size? _lastImageAreaSize;

  @override
  void initState() {
    super.initState();
    _textEditingController.text = ''; // Start empty or with a hint
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _isResizingBrush.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maskState = ref.watch(maskProvider);
    final imageEditingState = ref.watch(imageEditingProvider);
    final imageEditingNotifier = ref.read(imageEditingProvider.notifier);

    // Listen for errors
    ref.listen(imageEditingProvider, (previous, next) {
      if (next.status == ImageGenerationStatus.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.errorMessage}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Image'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. The Canvas Area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _lastImageAreaSize = constraints.biggest;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Show edited image if available, otherwise show original
                    if (imageEditingState.result != null)
                      Image.memory(
                        imageEditingState.result!,
                        fit: BoxFit.contain,
                      )
                    else
                      Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                      ),
                    
                    // Masking Canvas
                    if (imageEditingState.status != ImageGenerationStatus.loading)
                      Positioned.fill(
                        child: ClipRect(
                          child: const MaskingCanvas(),
                        ),
                      ),
                    
                    // Loading Overlay
                    if (imageEditingState.status == ImageGenerationStatus.loading)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Generating...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                     // Brush Size Preview (Center Overlay)
                     ValueListenableBuilder<bool>(
                      valueListenable: _isResizingBrush,
                      builder: (context, isResizing, child) {
                        if (!isResizing) return const SizedBox.shrink();
                        return Center(
                          child: IgnorePointer(
                            child: Container(
                              width: maskState.brushSize,
                              height: maskState.brushSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                color: Colors.red.withOpacity(0.5),
                              ),
                            ),
                          ),
                        );
                      },
                     ),

                     // Floating Toolbar (Undo/Redo/Clear)
                     Positioned(
                        top: 16,
                        right: 16,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'undo',
                              onPressed: maskState.paths.isEmpty
                                  ? null
                                  : () => ref.read(maskProvider.notifier).undo(),
                              backgroundColor: maskState.paths.isEmpty ? Colors.grey : null,
                              child: const Icon(Icons.undo),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'redo',
                              onPressed: maskState.redoPaths.isEmpty
                                  ? null
                                  : () => ref.read(maskProvider.notifier).redo(),
                              backgroundColor: maskState.redoPaths.isEmpty ? Colors.grey : null,
                              child: const Icon(Icons.redo),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'clear',
                              onPressed: maskState.paths.isEmpty
                                  ? null
                                  : () => ref.read(maskProvider.notifier).clear(),
                              backgroundColor: Colors.red.shade100,
                              foregroundColor: Colors.red,
                              elevation: 0,
                              child: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),

                      // Hidden widget to pass size to button via a provider or just closure? 
                      // Since we are in a build method, we can't easily pass this size to the button 
                      // which is in a separate part of the column unless we store it.
                      // HOWEVER, `imageAreaSize` is available here. 
                      // But the Button is OUTSIDE this LayoutBuilder.
                      // We need to restructure slightly so the button has access to this size.
                      // OR, simpler: We wrap the WHOLE BODY in a LayoutBuilder? 
                      // No, the Column splits it.
                      // Let's use a ValueNotifier or just Calculator in the button using the same logic?
                      // No, "same logic" is hard because of Expanded.
                      
                      // Better approach: Store the size in a specialized provider or widget state?
                      // Simplest: The generate button needs this size.
                      // We can use a `Builder` around the button and `context.findRenderObject`? No.
                      
                      // Let's modify the architecture slightly:
                      // The `imageAreaSize` is needed when `editText` is CALLED.
                      // We can store it in a member variable `_currentImageAreaSize` inside `build` 
                      // (updating it whenever this LayoutBuilder runs).
                      // Since build runs before interaction, it should be safe.
                      // Let's add `WidgetsBinding.instance.addPostFrameCallback` to update it? 
                      // No, just assign it. It's a stateless calculation during build.
                      // Ideally use a State variable.
                  ],
                );
              },
            ),
          ),

          // 3. Bottom Controls
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, controlConstraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brush Size Slider
                    Row(
                      children: [
                        const Icon(Icons.brush, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Brush Size: ${maskState.brushSize.toInt()}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Expanded(
                          child: Slider(
                            value: maskState.brushSize,
                            min: 5,
                            max: 100,
                            activeColor: Theme.of(context).colorScheme.primary,
                            onChangeStart: (_) => _isResizingBrush.value = true,
                            onChangeEnd: (_) => _isResizingBrush.value = false,
                            onChanged: (value) =>
                                ref.read(maskProvider.notifier).setBrushSize(value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Prompt Input
                    TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText: _promptService.getRandomPrompt(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.auto_awesome_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.shuffle),
                          tooltip: 'Suggest Prompt',
                          onPressed: () {
                             // Update the hint by rebuilding? 
                             // Or better, set the text directly if empty, or just update hint.
                             // For now, let's set the text for visibility.
                             _textEditingController.text = _promptService.getRandomPrompt();
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      maxLines: 1,
                      textInputAction: TextInputAction.done,
                    ),
                    
                    const SizedBox(height: 16),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: imageEditingState.status == ImageGenerationStatus.loading
                            ? null
                            : () {
                                if (_textEditingController.text.isNotEmpty && _lastImageAreaSize != null) {
                                  imageEditingNotifier.editText(
                                    widget.imageFile,
                                    _textEditingController.text,
                                    maskState.paths,
                                    maskState.brushSize,
                                    _lastImageAreaSize!,
                                    currentEditedImage: imageEditingState.result,
                                  ).then((_) {
                                    if (imageEditingState.result != null) {
                                      _localStorage.saveImage(imageEditingState.result!);
                                      ref.read(maskProvider.notifier).clear();
                                      _textEditingController.clear();
                                    }
                                  });
                                } else if (_textEditingController.text.isEmpty) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a prompt')),
                                  );
                                }
                              },
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Generate'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

