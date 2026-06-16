import 'package:campeando_frontend/app.dart';
import 'package:campeando_frontend/core/data/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Smoke test: Verify App load', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    // Build our app and trigger a frame.
    await tester.pumpWidget(CampeandoApp(storageService: storageService));

    // Since we now use go_router, the initial screen might be different
    // or take time to load (FutureBuilder in router).
    await tester.pumpAndSettle();

    // Verify that we are on some screen (e.g. catalog if not logged in)
    expect(find.text('Catálogo de Eventos'), findsOneWidget);
  });
}
