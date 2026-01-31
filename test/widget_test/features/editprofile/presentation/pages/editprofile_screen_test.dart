import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_hike/core/services/storage/user_session_service.dart';
import 'package:just_hike/features/auth/presentation/state/user_auth_state.dart';
import 'package:just_hike/features/auth/presentation/view_model/user_auth_viewmodel.dart';
import 'package:just_hike/features/editprofile/presentation/pages/editprofile_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock class
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Test Notifier for AuthViewmodel
class TestAuthNotifier extends AuthViewmodel {
  @override
  AuthState build() {
    return AuthState(
      status: AuthStatus.initial,
      authEntity: null,
      errorMessage: null,
    );
  }
}

void main() {
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    when(() => mockSharedPreferences.getString(any())).thenReturn(null);
    when(() => mockSharedPreferences.getBool(any())).thenReturn(false);
  });

  testWidgets('Should display Edit Profile title in AppBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          authViewmodelProvider.overrideWith(() => TestAuthNotifier()),
        ],
        child: const MaterialApp(home: Editprofile()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
  });

  testWidgets('Should display all text fields for profile editing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          authViewmodelProvider.overrideWith(() => TestAuthNotifier()),
        ],
        child: const MaterialApp(home: Editprofile()),
      ),
    );
    await tester.pumpAndSettle();

    // Check for all text fields
    expect(find.byType(TextFormField), findsNWidgets(4));

    // Verify labels
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Bio'), findsOneWidget);
  });

  testWidgets('Should display Save Changes and Cancel buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          authViewmodelProvider.overrideWith(() => TestAuthNotifier()),
        ],
        child: const MaterialApp(home: Editprofile()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Save Changes'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Should allow entering text in name field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          authViewmodelProvider.overrideWith(() => TestAuthNotifier()),
        ],
        child: const MaterialApp(home: Editprofile()),
      ),
    );
    await tester.pumpAndSettle();

    // Find the name text field (first TextFormField)
    final nameField = find.byType(TextFormField).first;

    // Clear and enter new text
    await tester.enterText(nameField, 'Sudip Ch');
    await tester.pumpAndSettle();

    expect(find.text('Sudip Ch'), findsOneWidget);
  });

  testWidgets('Should display profile picture change option', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          authViewmodelProvider.overrideWith(() => TestAuthNotifier()),
        ],
        child: const MaterialApp(home: Editprofile()),
      ),
    );
    await tester.pumpAndSettle();

    // Check for change profile picture text
    expect(find.text('Change Profile Picture'), findsOneWidget);

    // Check for camera icon in the profile section
    expect(find.byIcon(Icons.camera_alt), findsWidgets);
  });
}
