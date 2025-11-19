# ImaGen CHANGELOG

## Version 0.0.2

### Authentication, Data Connect & Enhanced Editing

This release introduces secure authentication, robust data management, and significant improvements to the editing workflow.

**New Features:**

*   **Firebase Authentication:**
    *   Implemented Anonymous Sign-In ("Enter as Guest") for quick and secure access.
    *   Added a dedicated `LoginPage`.
    *   Secured app routes using `GoRouter` redirects (guards).
    *   Added Logout functionality to the Home Page.
*   **Advanced Editing Controls:**
    *   **Undo/Redo System:** Implemented a full Command Pattern for the Magic Mask, allowing users to undo and redo drawing actions.
    *   **UI Enhancements:** Added a "Thinking" overlay with spinner during AI processing and improved the styling of the bottom control panel.
*   **AI Service Layer:**
    *   Structured the `GeminiAiImageEditingService` for future integration with the real Google Gemini API.
    *   Refactored the service interface to support cleaner dependency injection.
*   **Backend & Data:**
    *   **Firebase Data Connect:** Configured and deployed the Data Connect service with a PostgreSQL backend.
    *   **Schema Design:** Defined a strongly-typed GraphQL schema (`User`, `ImageEdit`) to store user history and edits.

**Improvements:**

*   **Home Page Redesign:** Updated the Home Page with a modern, card-based layout and better iconography.
*   **Project Structure:** Organized Data Connect configuration and connectors.

## Version 0.0.1

### Initial Release & Core Features

This is the first version of the ImaGen application, establishing the core architecture and primary features for AI-powered image editing.

**Features:**

*   **Project Initialization:** Set up a new Flutter project with a clean, feature-based architecture (`features/`, `core/`, `data/`, `domain/`, `presentation/`).
*   **Dependency Management:** Added and configured core dependencies including `flutter_riverpod` for state management, `go_router` for navigation, `image_picker` for image selection, and `firebase_core`/`firebase_ai` for the upcoming AI integration.
*   **Core App Setup:**
    *   Initialized Firebase within the application.
    *   Configured a modern, dark theme using Material 3.
    *   Set up routing between the home and image editing pages.
*   **Image Input:** Implemented the home screen allowing users to select an image from their gallery or capture a new one with the camera.
*   **Magic Canvas:**
    *   Created the `MaskingCanvas`, a custom `CustomPainter` widget that allows users to draw a semi-transparent red mask over an image using touch gestures.
    *   Integrated a slider to dynamically adjust the brush size.
    *   Added "Undo" and "Clear" functionality to manage the mask state.
*   **State Management:**
    *   Utilized Riverpod with `StateNotifier` to manage the state of the drawing mask (`MaskProvider`) and the image editing process (`ImageEditingProvider`).
*   **Mock AI Integration:**
    *   Set up a mock `AiImageEditingService` to simulate the behavior of a generative AI model.
    *   The application now shows a loading indicator while "processing" and displays a placeholder result image, providing a complete end-to-end user flow.
*   **Documentation:** Created `blueprint.md` to track the project's vision, architecture, and development plan.
