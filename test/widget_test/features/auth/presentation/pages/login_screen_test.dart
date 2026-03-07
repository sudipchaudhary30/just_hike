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
import 'package:just_hike/features/dashboard/presentation/screens/bottom_screen_layout.dart';

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
  int loginCallCount = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  AuthState build() => const AuthState();

  @override
  Future<void> login({required String email, required String password}) async {
    loginCallCount++;
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
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
  }

  testWidgets('shows Log In heading and subtitle', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Start your Adventure today.'), findsOneWidget);
  });

  testWidgets('shows email and password fields', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('shows login and social actions', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    expect(find.widgetWithText(ElevatedButton, 'Log in'), findsOneWidget);
    expect(find.text('Login with Google'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('toggles password visibility icon', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('allows entering email and password', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    await tester.enterText(find.byType(TextFormField).at(0), 'a@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.pump();

    expect(find.text('a@test.com'), findsOneWidget);
    expect(find.text('secret'), findsOneWidget);
  });

  testWidgets('shows email required validation on empty login', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(notifier.loginCallCount, 0);
  });

  testWidgets('calls login with trimmed email', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    await tester.enterText(find.byType(TextFormField).at(0), '  a@test.com  ');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
    await tester.pump();

    expect(notifier.loginCallCount, 1);
    expect(notifier.lastEmail, 'a@test.com');
    expect(notifier.lastPassword, 'secret');
  });

  testWidgets('navigates to RegisterScreen on Create Account tap', (
    tester,
  ) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });



  testWidgets('forgot password tap keeps user on LoginScreen', (tester) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('navigates to BottomScreenLayout when state is authenticated', (
    tester,
  ) async {
    final notifier = TestAuthNotifier();

    await tester.pumpWidget(buildTestWidget(notifier));

    notifier.emitState(const AuthState(status: AuthStatus.authenticated));
    await tester.pumpAndSettle();

    expect(find.byType(BottomScreenLayout), findsOneWidget);
  });
}
