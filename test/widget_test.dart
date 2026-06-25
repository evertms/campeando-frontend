import 'package:campeando_frontend/app.dart';
import 'package:campeando_frontend/core/data/api_client.dart';
import 'package:campeando_frontend/core/data/storage_service.dart';
import 'package:campeando_frontend/features/auth/data/auth_repository_impl.dart';
import 'package:campeando_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:campeando_frontend/features/auth/presentation/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Smoke test: Verify App load', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    // Mismo cableado que main(): la sesión se resuelve antes de montar la UI.
    final apiClient = ApiClient(storageService: storageService);
    final AuthRepository authRepository = AuthRepositoryImpl(
      apiClient: apiClient,
    );
    final authProvider = AuthProvider(
      authRepository: authRepository,
      storageService: storageService,
    );
    apiClient.onUnauthorized = authProvider.handleUnauthorized;
    await authProvider.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      CampeandoApp(
        storageService: storageService,
        apiClient: apiClient,
        authRepository: authRepository,
        authProvider: authProvider,
      ),
    );

    // The first frame might show a loader or the initial screen.
    // We expect the app to at least build a MaterialApp or a Scaffold.
    expect(find.byType(MaterialApp), findsOneWidget);

    await tester.pump();

    // Check for a Scaffold which should be present in any of our screens.
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
