import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_hike/features/auth/presentation/pages/login_screen.dart';
import 'package:just_hike/features/auth/presentation/pages/register_screen.dart';
import 'package:just_hike/features/auth/presentation/state/user_auth_state.dart';
import 'package:just_hike/features/auth/presentation/view_model/user_auth_viewmodel.dart';

const List<int> _transparentImageBytes = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x60,
  0x60,
  0x60,
  0x00,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0xA5,
  0xF6,
  0x45,
  0x40,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

class TestAssetBundle extends CachingAssetBundle {
  static final ByteData _manifestBinData = ByteData.sublistView(
    const StandardMessageCodec().encodeMessage(<String, List<String>>{})!,
  );

  static final ByteData _manifestJsonData = ByteData.sublistView(
    Uint8List.fromList(utf8.encode('{}')),
  );

  static final ByteData _imageData = ByteData.sublistView(
    Uint8List.fromList(_transparentImageBytes),
  );

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('AssetManifest.bin')) return _manifestBinData;
    if (key.endsWith('AssetManifest.json')) return _manifestJsonData;
    return _imageData;
  }
}

class TestAuthNotifier extends AuthViewmodel {
  int registerCallCount = 0;
  String? lastName;
  String? lastEmail;
  String? lastPassword;

  @override
  AuthState build() => const AuthState();

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    registerCallCount++;
    lastName = fullName;
    lastEmail = email;
    lastPassword = password;
  }

  void emitState(AuthState newState) {
    state = newState;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget(TestAuthNotifier notifier) {
    return ProviderScope(
      overrides: [authViewmodelProvider.overrideWith(() => notifier)],
      child: DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
  }

  testWidgets('shows Sign Up heading and subtitle', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    expect(find.text('Sign Up'), findsWidgets);
    expect(find.text('Create your account.'), findsOneWidget);
  });

  testWidgets('shows full name, email and password fields', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('shows signup buttons and login text', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    expect(find.text('Sign Up with Google'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('toggles password visibility', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('shows validation errors for empty required fields', (
    tester,
  ) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    expect(find.text('Full Name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(notifier.registerCallCount, 0);
  });

  testWidgets('calls register with entered values', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    await tester.enterText(find.byType(TextFormField).at(0), 'Sudip');
    await tester.enterText(find.byType(TextFormField).at(1), 'sudip@test.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    expect(notifier.registerCallCount, 1);
    expect(notifier.lastName, 'Sudip');
    expect(notifier.lastEmail, 'sudip@test.com');
    expect(notifier.lastPassword, 'password123');
  });

  testWidgets('navigates to LoginScreen when state becomes registered', (
    tester,
  ) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    notifier.emitState(const AuthState(status: AuthStatus.registered));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('keeps user on RegisterScreen when Login text is tapped', (
    tester,
  ) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('shows registration error snackbar when state is error', (
    tester,
  ) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    notifier.emitState(
      const AuthState(status: AuthStatus.error, errorMessage: 'server error'),
    );
    await tester.pump();

    expect(find.text('Registration failed. Please try again'), findsOneWidget);
  });
}
