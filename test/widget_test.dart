import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_buddy/app.dart';
import 'package:focus_buddy/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('focus_buddy_test_');
    await StorageService.instance.initForTests(tempDir.path);
  });

  testWidgets('FocusBuddy home renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FocusBuddyApp()));

    expect(find.text('FocusBuddy'), findsOneWidget);
    expect(find.text('Commencer une session'), findsOneWidget);
  });
}
