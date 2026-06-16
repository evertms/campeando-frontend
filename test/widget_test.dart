import 'package:campeando_frontend/app.dart';
import 'package:campeando_frontend/core/data/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Smoke test: Verify App load', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    // Build our app and trigger a frame.
    await tester.pumpWidget(CampeandoApp(storageService: storageService));

    // The first frame might show a loader or the initial screen.
    // We expect the app to at least build a MaterialApp or a Scaffold.
    expect(find.byType(MaterialApp), findsOneWidget);
    
    await tester.pump();
    
    // Check for a Scaffold which should be present in any of our screens.
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
