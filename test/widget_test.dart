import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hardlist/main.dart';
import 'package:provider/provider.dart';
import 'package:hardlist/theme_notifier.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const MyApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
