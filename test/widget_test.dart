import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corpo_sostenibile/main.dart';
import 'package:corpo_sostenibile/core/constants/app_constants.dart';

void main() {
  testWidgets('App si avvia correttamente', (WidgetTester tester) async {
    // Costruisce l'app con ProviderScope per Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: CorpoSostenibileApp(),
      ),
    );

    // Verifica che il widget principale sia presente
    expect(find.byType(CorpoSostenibileApp), findsOneWidget);

    // Verifica che lo splash screen mostri il nome dell'app
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Avanza il timer dello splash per completare la navigazione
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
