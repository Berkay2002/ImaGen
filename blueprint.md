# ImaGen - AI-Powered Generative Image Editing

## Overview

ImaGen is a comprehensive Flutter application for AI-powered generative image editing. It's an advanced image manipulation tool where users can upload an image, use a gesture-based "Magic Brush" to paint a mask over specific objects, and use text prompts to instruct an AI (Firebase AI/Gemini) to replace or edit that specific area (In-painting).

## Style, Design, and Features

### Architecture

*   **Framework:** Flutter (Latest stable)
*   **Architecture:** Clean Architecture (Feature-based folder structure: `features/`, `core/`, `data/`, `domain/`, `presentation/`)
*   **State Management:** Riverpod 2.0 (with code generation)
*   **Design Patterns:**
    *   **Observer Pattern:** Use Streams/Riverpod to manage UI state reactively.
    *   **Command Pattern:** Implement a robust Undo/Redo stack for the painting mask actions.

### Key Features & UI Components

*   **Feature A: Image Input:** A sleek home screen allowing users to pick from Gallery or take a photo using `image_picker`.
*   **Feature B: The "Magic Canvas" (Custom Widget - Critical):**
    *   Create a custom widget named `MaskingCanvas` using `CustomPainter` and `GestureDetector`.
    *   It must overlay the selected image.
    *   Users must be able to draw (pan) with their finger to create a red, semi-transparent mask path.
    *   Include a slider to adjust brush size.
    *   Include "Undo" and "Clear" buttons that manipulate the path history.
*   **Feature C: AI Integration:**
    *   A text field for the user's prompt (e.g., "Replace the cat with a dog").
    *   A service layer setup to communicate with Google Gemini AI (Gemini API) or Firebase AI.

### Visual Style

*   **Theme:** Modern Dark Mode, Material 3 design system.
*   **UX:** Show loading spinners/shimmer effects while the "AI is thinking."

## Current Plan

1.  **Create `blueprint.md`:** Create the `blueprint.md` file to document the project's overview, features, and the plan for the current request.
2.  **Add Dependencies:** Add all the necessary dependencies to the `pubspec.yaml` file. This includes `flutter_riverpod`, `riverpod_annotation`, `image_picker`, `go_router`, `firebase_core`, and `firebase_ai`. I'll also add `build_runner` and `riverpod_generator` as dev dependencies.
3.  **Update `main.dart`:** Modify the `lib/main.dart` file to initialize Firebase, set up the Riverpod provider scope, and configure the GoRouter. I will also define the dark theme for the application.
4.  **Create Home Page:** Create the initial UI for the home page in `lib/features/home/presentation/pages/home_page.dart`. This will include the basic layout and buttons for picking an image from the gallery or taking a photo.
5.  **Create Image Editing Page:** Create the `image_editing_page.dart` file in `lib/features/image_editing/presentation/pages/`. This will be the main screen for the image editing functionality.
