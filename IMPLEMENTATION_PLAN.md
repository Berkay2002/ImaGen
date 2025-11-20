# Implementation Plan for ImaGen UI/UX Enhancements

This document outlines the detailed implementation steps for improving the user experience and user interface of the ImaGen application, broken down into three phases.

## Phase 1: Implementation Plan - Personal Gallery

This phase focuses on allowing users to save and view their creations.

1.  **Add Dependencies:**
    *   [COMPLETED] Add the `path_provider` package to `pubspec.yaml` to find the correct local path for storing images.
    *   [COMPLETED] Run `flutter pub get`.

2.  **Create a Local Storage Service:**
    *   [COMPLETED] Create a new file: `lib/features/gallery/data/datasources/local_image_storage.dart`.
    *   [COMPLETED] This class will handle saving and loading images from the device.
    *   [COMPLETED] **`saveImage(Uint8List imageBytes)` method:**
        *   [COMPLETED] Get the application's document directory using `path_provider`.
        *   [COMPLETED] Generate a unique filename (e.g., using a timestamp: `IMG_${DateTime.now().millisecondsSinceEpoch}.png`).
        *   [COMPLETED] Write the `imageBytes` to a file at that path.
    *   [COMPLETED] **`loadImages()` method:**
        *   [COMPLETED] Get the application's document directory.
        *   [COMPLETED] List all files in the directory.
        *   [COMPLETED] Return a list of `File` objects.

3.  **Build the Gallery UI:**
    *   [COMPLETED] Create a new page: `lib/features/gallery/presentation/pages/gallery_page.dart`.
    *   [COMPLETED] This will be a `StatefulWidget`.
    *   [COMPLETED] In `initState`, call the `loadImages()` method from the storage service.
    *   [COMPLETED] The `build` method will contain:
        *   [COMPLETED] A `Scaffold` with an `AppBar` titled "My Creations".
        *   [COMPLETED] A `FutureBuilder` or a loading state check. If loading, show a `CircularProgressIndicator`.
        *   [COMPLETED] If there are no images, display a message like "Your generated images will appear here."
        *   [COMPLETED] A `GridView.builder` to display the images. Each item will be an `Image.file()` widget, showing an image from the loaded list.

4.  **Integrate Saving and Navigation:**
    *   [COMPLETED] In `image_editing_page.dart`, after a successful AI image generation, call the `saveImage()` method from your new service.
    *   [COMPLETED] In the `AppBar` of `home_page.dart` (or another central location), add an `IconButton` (e.g., `Icons.photo_library`) that navigates the user to the `GalleryPage`.

## Phase 2: Implementation Plan - Inspiration & Prompt Assistance

This phase focuses on making it easier for users to start creating.

1.  **Create a Prompt Suggestion Service:**
    *   [COMPLETED] Create a new file: `lib/features/image_editing/domain/services/prompt_suggestion_service.dart`.
    *   [COMPLETED] Inside, define a `const` list of 15-20 diverse, high-quality example prompts.
    *   [COMPLETED] Create a public method, `String getRandomPrompt()`, that uses `dart:math`'s `Random` to select and return a random prompt from the list.

2.  **Update the Image Editing UI:**
    *   [COMPLETED] Navigate to `lib/features/image_editing/presentation/pages/image_editing_page.dart`.
    *   [COMPLETED] In the `initState` method, call `getRandomPrompt()` and store the result in a variable.
    *   [COMPLETED] Find the prompt `TextField`. In its `InputDecoration`, set the `hintText` to the random prompt you fetched.
    *   [COMPLETED] Add an `IconButton` (e.g., `Icons.shuffle` or `Icons.lightbulb`) next to the `TextField`.
    *   [COMPLETED] The `onPressed` callback for this new button will:
        *   [COMPLETED] Call `getRandomPrompt()` again.
        *   [COMPLETED] Update the `TextEditingController`'s text with the new prompt, replacing what the user has typed.

## Phase 3: Implementation Plan - State Management Feedback

This phase focuses on providing clear feedback to the user during generation.

1.  **Enhance the `ImageEditingProvider`:**
    *   [COMPLETED] In `lib/features/image_editing/presentation/providers/image_editing_provider.dart`, define an `enum` at the top of the file: `enum ImageGenerationStatus { initial, loading, success, error }`.
    *   [COMPLETED] Add a private field to the provider: `ImageGenerationStatus _status = ImageGenerationStatus.initial;`.
    *   [COMPLETED] Add a public getter: `ImageGenerationStatus get status => _status;`.
    *   [COMPLETED] Add another field to hold an error message: `String? _errorMessage;` with a corresponding getter.
    *   [COMPLETED] Modify the primary image generation method (e.g., `generateImage`):
        *   [COMPLETED] At the start of the method, set `_status = ImageGenerationStatus.loading;` and call `notifyListeners()`.
        *   [COMPLETED] Wrap the entire network request and processing logic in a `try...catch` block.
        *   [COMPLETED] On success (inside `try`), set `_status = ImageGenerationStatus.success;`.
        *   [COMPLETED] On failure (inside `catch`), set `_status = ImageGenerationStatus.error;`, store a user-friendly error message in `_errorMessage`, and log the actual error.
        *   [COMPLETED] Call `notifyListeners()` at the end of the `try` and `catch` blocks.

2.  **Update the UI to Reflect State:**
    *   [COMPLETED] In `lib/features/image_editing/presentation/pages/image_editing_page.dart`, use a `Consumer<ImageEditingProvider>` to listen for changes.
    *   [COMPLETED] **Handle Loading:** Check `provider.status`. If it is `ImageGenerationStatus.loading`:
        *   [COMPLETED] Disable the "Generate" button.
        *   [COMPLETED] Display a `CircularProgressIndicator` overlay on top of the image area.
    *   [COMPLETED] **Handle Errors:** If `provider.status` is `ImageGenerationStatus.error`:
        *   [COMPLETED] Use a `post-frame callback` (`WidgetsBinding.instance.addPostFrameCallback`) to show a `SnackBar` with the `provider.errorMessage`.
        *   [COMPLETED] After showing the error, you may want to call a method on the provider to reset the status back to `initial`.
    *   [COMPLETED] Ensure the UI returns to its normal, interactive state when the status is `initial` or `success`.