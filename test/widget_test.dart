import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corpo_sostenibile/main.dart';

void main() {
  testWidgets(
    'App si costruisce senza errori',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Costruisce l'app con ProviderScope per Riverpod
        await tester.pumpWidget(
          const ProviderScope(
            child: CorpoSostenibileApp(),
          ),
        );

        // Verifica che il widget principale sia presente
        expect(find.byType(CorpoSostenibileApp), findsOneWidget);

        // Verifica che sia un MaterialApp
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    },
  );
}
