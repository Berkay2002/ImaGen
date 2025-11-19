# Plan: Complete ImaGen MVP with Firebase AI Logic Integration

Integrate Firebase AI Logic SDK to access Gemini models seamlessly without API key management. Use the "hacker strategy" of compositing red mask onto image for semantic inpainting with `gemini-2.5-flash-image` model. Achieve 100% MVP completion with robust image response parsing and optimized prompting.

## Steps

1. **Fix Path type conflict** in [`image_editing_provider.dart`](lib/features/image_editing/presentation/providers/image_editing_provider.dart) by adding `import 'dart:ui' as ui;` at top and changing `List<Path>` parameter to `List<ui.Path>` on line 54

2. **Add Firebase AI Logic SDK** to [`pubspec.yaml`](pubspec.yaml) replacing `google_generative_ai: ^0.4.0` with `firebase_ai: ^latest` in dependencies section, then run `flutter pub get`

3. **Create mask compositor utility** in new [`lib/core/utils/mask_compositor.dart`](lib/core/utils/mask_compositor.dart) with function `Future<Uint8List> compositeMaskOntoImage(File originalImage, List<ui.Path> paths, double brushSize)` that uses `PictureRecorder`, `Canvas`, and `ImageByteFormat.png` to draw red semi-transparent overlay

4. **Implement GeminiAiImageEditingService** in [`gemini_ai_image_editing_service.dart`](lib/features/image_editing/data/datasources/gemini_ai_image_editing_service.dart) using `FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash-image', generationConfig: GenerationConfig(responseModalities: [ResponseModalities.image]))` with robust response parsing handling `response.inlineDataParts`, base64 decoding, and error fallbacks

5. **Switch to real AI service** in [`image_editing_provider.dart`](lib/features/image_editing/presentation/providers/image_editing_provider.dart) changing `imageEditingServiceProvider` from `MockAiImageEditingService()` to `GeminiAiImageEditingService()`, passing composite image from mask compositor

6. **Fix test import path** in [`test/widget_test.dart`](test/widget_test.dart) changing `import 'package:myapp/main.dart';` to `import 'package:my_app/main.dart';`

## Further Considerations

1. **Prompt Engineering:** Use semantic inpainting prompt: "This image contains a red highlighted area that marks the region to edit. Transform ONLY the content within the red highlighted area to: [USER_PROMPT]. Keep all other parts of the image exactly as they are, preserving the original lighting, perspective, and composition." - explicit vs minimal wording?

2. **Image Preprocessing:** Resize composite images larger than 2048px in either dimension before API call to stay under 20MB limit and reduce latency - use `dart:ui` Image scaling or `image` package?

3. **Response Robustness:** Handle cases where Gemini returns text-only (no image generated), multiple images in parts array, or safety filter blocks - should we show original image with error message overlay vs blank error screen?
