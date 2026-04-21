import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pula_pay/main.dart';

void main() {
  testWidgets('app routes from splash to login when signed out', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
