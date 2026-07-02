import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibemastery/main.dart';

void main() {
  testWidgets('App launches to the home screen without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SightWordApp());
    await tester.pump();

    expect(find.byType(Scaffold), findsWidgets);
  });
}
