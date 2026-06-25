import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/data/api_client.dart';
import 'core/data/storage_service.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use path-based URLs (no '#') so deep links like
  // /events/:id/register are parsed by the router instead of being
  // ignored by the default hash strategy (which always boots at '/').
  // No-op on non-web platforms.
  usePathUrlStrategy();

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  // Cableamos el núcleo de auth acá para resolver la sesión ANTES de construir
  // la UI. Así el router nunca arranca en AuthStatus.initial y se elimina el
  // spinner infinito al reabrir. El ApiClient se comparte con el resto de
  // repositorios (en CampeandoApp) para que el refresh-on-401 aplique a todos.
  final apiClient = ApiClient(storageService: storageService);
  final AuthRepository authRepository = AuthRepositoryImpl(apiClient: apiClient);
  final authProvider = AuthProvider(
    authRepository: authRepository,
    storageService: storageService,
  );
  apiClient.onUnauthorized = authProvider.handleUnauthorized;

  // initialize() ya maneja sus errores internamente (cae a unauthenticated).
  // El timeout es una última red de seguridad ante un cuelgue inesperado.
  try {
    await authProvider.initialize().timeout(const Duration(seconds: 12));
  } catch (_) {
    // Si algo se colgó por completo, arrancamos igual: el estado quedó
    // resuelto (o se resolverá a unauthenticated) y la UI no queda colgada.
  }

  runApp(
    CampeandoApp(
      storageService: storageService,
      apiClient: apiClient,
      authRepository: authRepository,
      authProvider: authProvider,
    ),
  );
}
