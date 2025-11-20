import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:my_app/features/auth/data/auth_repository.dart';
import 'package:my_app/features/gallery/data/datasources/local_image_storage.dart';

class MockLocalImageStorage implements LocalImageStorage {
  @override
  Future<List<File>> loadImages() async => Future.value([]);

  @override
  Future<File> saveImage(Uint8List imageBytes) async {
    throw UnimplementedError();
  }
}

void main() {
  final user = MockUser(
    isAnonymous: false,
    uid: 'someuid',
    email: 'bob@somedomain.com',
    displayName: 'Bob',
  );
  final auth = MockFirebaseAuth(mockUser: user);

  testWidgets('HomePage UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(AuthRepository(auth)),
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the main title is present.
    expect(find.text('Start Creating'), findsOneWidget);
  });

  testWidgets('GalleryPage UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(AuthRepository(auth)),
          authStateProvider.overrideWith((ref) => Stream.value(user)),
          localImageStorageProvider.overrideWithValue(MockLocalImageStorage()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap the gallery icon
    await tester.tap(find.byTooltip('My Creations'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify that the gallery page is displayed and shows the empty message.
    expect(find.text('Your generated images will appear here.'), findsOneWidget);
  });
}