import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediguide_app/main.dart';

void main() {
  testWidgets('Login screen loads correctly', (WidgetTester tester) async {

    // Build the app
    await tester.pumpWidget(const MediGuideApp());

    // Verify text fields exist (username + password)
    expect(find.byType(TextField), findsNWidgets(2));

    // Verify login button exists
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Verify app title exists
    expect(find.text('MediGuide AI'), findsOneWidget);
  });
}