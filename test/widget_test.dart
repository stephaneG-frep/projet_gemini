import 'dart:io';

import 'package:flutter/material.dart';
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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('FocusBuddy'), findsOneWidget);
    expect(find.text('Une app pour retrouver l elan'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Passer'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.scrollUntilVisible(
      find.text('Commencer une session'),
      160,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Commencer une session'), findsOneWidget);
  });
}
