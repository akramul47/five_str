import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:five_str/app.dart';

void main() {
  testWidgets('App boots without crashing', (tester) async {
    await tester.pumpWidget(const FiveStrApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
