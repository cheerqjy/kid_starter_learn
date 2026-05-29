import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kid_starter/app/screens/home_screen.dart';

void main() {
  testWidgets('home screen shows expanded learning categories',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('Phonics'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
    expect(find.text('Flowers'), findsOneWidget);
  });
}
