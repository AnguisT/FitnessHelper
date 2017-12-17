// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/login.dart';

void main() {
  testWidgets('Login in system', (WidgetTester tester) async {
    await tester.pumpWidget(new Login());

    // expect(find.text('Login'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Vlad');

    await tester.enterText(find.byType(TextField).last, 'vlad');

    await tester.tap(find.widgetWithText(RaisedButton, 'Login/SignUp'));
    await tester.pump();

    // expect(find.text('Home'), findsOneWidget);
    // expect(find.byType(ListTile), findsOneWidget);
  });
}
