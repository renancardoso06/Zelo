// Smoke test: garante que o app inicializa e mostra a tela de login.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zelo_app/main.dart';
import 'package:zelo_app/providers/app_provider.dart';

void main() {
  testWidgets('App inicia na tela de login', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider()..init(),
        child: const ZeloApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zelo'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
