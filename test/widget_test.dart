import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pula_pay/main.dart';

void main() {
  testWidgets('app routes from splash to login when signed out', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
