import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart' show Size;
import 'package:my_app/core/utils/mask_compositor.dart';
import 'package:my_app/features/image_editing/data/datasources/ai_image_editing_service.dart';

class GeminiAiImageEditingService implements AiImageEditingService {
  GeminiAiImageEditingService();

  @override
  Future<Uint8List> editText(
    File image,
    String prompt,
    List<ui.Path> mask,
    double brushSize,
    Size screenSize, {
    Uint8List? currentEditedImage,
  }) async {
    try {
      // Step 1: Composite the red mask onto the current image (edited or original)
      // Use currentEditedImage if available, otherwise use original file
      final compositeImageBytes = await compositeMaskOntoImage(
        image,
        mask,
        brushSize,
        screenSize: screenSize,
        baseImageBytes: currentEditedImage,
      );

      // Step 2: Resize if needed to stay under API limits
      final resizedImageBytes = await resizeImageIfNeeded(
        compositeImageBytes,
        maxDimension: 2048,
      );

      // Step 3: Initialize Firebase AI with Gemini model for image generation
      // Using gemini-2.5-flash-image (aka "nano banana") for image editing
      // IMPORTANT: Must include BOTH text and image in responseModalities
      final ai = FirebaseAI.googleAI();
      final model = ai.generativeModel(
        model: 'gemini-2.5-flash-image',
        generationConfig: GenerationConfig(
          responseModalities: [
            ResponseModalities.text,
            ResponseModalities.image,
          ],
        ),
      );

      // Step 4: Construct semantic inpainting prompt with better instructions
      final fullPrompt = _buildInpaintingPrompt(prompt);

      // Step 5: Create content with composite image
      final content = [
        Content.multi([
          InlineDataPart('image/png', resizedImageBytes),
          TextPart(fullPrompt),
        ])
      ];

      // Step 6: Generate content
      final response = await model.generateContent(content);

      // Step 7: Parse response robustly
      return _extractImageFromResponse(response, image);
    } catch (e) {
      print('GeminiAiImageEditingService Error: $e');
      rethrow;
    }
  }

  /// Builds a clear inpainting prompt based on user intent
  /// Supports: REMOVE, ADD, EDIT/REPLACE operations
  String _buildInpaintingPrompt(String userPrompt) {
    final lowerPrompt = userPrompt.toLowerCase().trim();

    // Check if user wants to remove/delete content
    if (lowerPrompt.contains('remove') ||
        lowerPrompt.contains('delete') ||
        lowerPrompt.contains('erase') ||
        lowerPrompt.contains('clear')) {
      return '''INPAINTING TASK: Content Removal

INPUT: An image with a RED MASK overlay indicating the exact area to remove.

INSTRUCTION: Remove all content within the red-masked region and fill it naturally.

EXECUTION STEPS:
1. Identify the red-masked area precisely
2. Remove everything in that region
3. Fill the space by extending surrounding textures, colors, and patterns
4. Match lighting and perspective seamlessly
5. Make it look like nothing was ever there

STRICT RULES:
- Do NOT add any new objects
- Do NOT add text or labels
- Only remove and fill naturally
- The red mask shows EXACTLY what to remove''';
    }

    // Check if user wants to add something new
    if (lowerPrompt.contains('add ') ||
        lowerPrompt.contains('insert') ||
        lowerPrompt.contains('put ') ||
        lowerPrompt.contains('place ') ||
        lowerPrompt.startsWith('a ') ||
        lowerPrompt.startsWith('an ')) {
      return '''INPAINTING TASK: Add New Content

INPUT: An image with a RED MASK overlay indicating where to add content.

INSTRUCTION: $userPrompt

EXECUTION STEPS:
1. Locate the red-masked area precisely - this is WHERE to add content
2. Generate the requested object/element
3. Place it within the red-masked region ONLY
4. Blend it naturally with lighting, shadows, and perspective
5. Ensure proper scale and proportions

STRICT RULES:
- Add content ONLY within the red-masked area
- Match the style and lighting of the original image
- Do NOT add text labels unless explicitly requested
- Make the addition look realistic and integrated''';
    }

    // Check if user wants to change color or appearance
    if (lowerPrompt.contains('change') ||
        lowerPrompt.contains('color') ||
        lowerPrompt.contains('blue') ||
        lowerPrompt.contains('red') ||
        lowerPrompt.contains('green') ||
        lowerPrompt.contains('yellow') ||
        lowerPrompt.contains('black') ||
        lowerPrompt.contains('white')) {
      return '''INPAINTING TASK: Modify Appearance/Color

INPUT: An image with a RED MASK overlay marking the EXACT object to modify.

INSTRUCTION: $userPrompt

EXECUTION STEPS:
1. Identify the object/region COVERED by the red mask
2. Apply ONLY the requested changes to that specific object
3. Keep the object's shape, structure, and position IDENTICAL
4. Preserve all surrounding areas completely unchanged
5. Maintain realistic lighting and shading on the modified object

STRICT RULES:
- Modify ONLY the object covered by the red mask
- Do NOT move, resize, or relocate the object
- Do NOT add new objects elsewhere in the image
- Do NOT add text labels
- The red mask shows EXACTLY what to change

EXAMPLE: If the mask is on a red dress and prompt is "change to blue", recolor THAT DRESS to blue, keeping everything else identical.''';
    }

    // Check if user wants to replace/transform content
    if (lowerPrompt.contains('replace') ||
        lowerPrompt.contains('transform') ||
        lowerPrompt.contains('make it') ||
        lowerPrompt.contains('turn into')) {
      return '''INPAINTING TASK: Replace/Transform Content

INPUT: An image with a RED MASK overlay marking what to replace.

INSTRUCTION: $userPrompt

EXECUTION STEPS:
1. Identify what is covered by the red mask
2. Replace it with the requested content
3. Keep the replacement in the SAME location as the original
4. Match lighting, style, and perspective
5. Blend seamlessly with surroundings

STRICT RULES:
- Replace ONLY what's in the red-masked area
- Keep all other parts unchanged
- Do NOT add new objects in different locations
- Do NOT add text labels
- Maintain realistic composition''';
    }

    // General/ambiguous transformation
    return '''INPAINTING TASK: Image Editing

INPUT: An image with a RED MASK overlay marking the area to edit.

INSTRUCTION: $userPrompt

EXECUTION STEPS:
1. Locate the red-masked region precisely
2. Apply the requested edit ONLY to that area
3. Keep everything else unchanged
4. Match lighting and style
5. Blend seamlessly

STRICT RULES:
- Edit ONLY the red-masked area
- Do NOT modify other parts
- Do NOT add text labels
- Make edits look natural''';
  }

  /// Extracts image data from Gemini response with robust error handling
  Future<Uint8List> _extractImageFromResponse(
    GenerateContentResponse response,
    File originalImage,
  ) async {
    try {
      // Check if response has inline data parts
      if (response.candidates.isNotEmpty) {
        final candidate = response.candidates.first;

        if (candidate.content.parts.isNotEmpty) {
          for (final part in candidate.content.parts) {
            // Look for inline data (image) parts
            if (part is InlineDataPart) {
              final imageBytes = part.bytes;

              if (imageBytes.isNotEmpty) {
                return imageBytes;
              }
            }
          }
        }
      }

      // Fallback 1: Check if there's text indicating an error
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        print('Gemini returned text instead of image: $text');
      }

      // Fallback 2: Return original image if no image was generated
      print('No image found in response, returning original image');
      return await originalImage.readAsBytes();
    } catch (e) {
      print('Error extracting image from response: $e');
      // Final fallback: return original image
      return await originalImage.readAsBytes();
    }
  }
}
