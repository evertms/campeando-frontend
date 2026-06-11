// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:campeando_frontend/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test: Verify HomeScreen titles', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CampeandoApp());

    // Verify that our titles are present.
    expect(find.text('Campeando - Demo UI'), findsOneWidget);
    expect(find.text('Módulos Implementados'), findsOneWidget);
    
    // Verify that the menu tiles are present.
    expect(find.text('Catálogo de Eventos'), findsOneWidget);
    expect(find.text('Detalle de Evento'), findsOneWidget);
    expect(find.text('Ingreso (Login)'), findsOneWidget);
  });
}
