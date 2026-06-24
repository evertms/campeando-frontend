import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:campeando_frontend/features/auth/presentation/auth_provider.dart';
import 'package:go_router/go_router.dart';

/// Escucha los deep links entrantes (`campeando://...`) y los traduce a una
/// ruta del [GoRouter].
///
/// El link puede traer el tenant correcto como query (`?tenant=<orgId>`).
/// Si el usuario ya está autenticado, se fuerza esa organización antes de
/// navegar, para evitar que un staff con la org equivocada seleccionada vea
/// un 403/404 al abrir una postulación de otra organización.
///
/// Solución temporal: el backend debería igualmente verificar que el usuario
/// pertenece a ese tenant; aquí solo ajustamos el `X-Tenant-Id` que se envía.
class DeepLinkHandler {
  final GoRouter router;
  final AuthProvider authProvider;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  DeepLinkHandler(this.router, this.authProvider);

  /// Maneja el link de arranque en frío (app cerrada) y se suscribe a los
  /// links que llegan con la app abierta.
  Future<void> init() async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      await _handle(initialLink);
    }
    _subscription = _appLinks.uriLinkStream.listen(_handle);
  }

  Future<void> _handle(Uri uri) async {
    final location = _locationFor(uri);
    if (location == null) return;

    // Forzar el tenant del link solo si ya hay sesión. Si está deslogueado,
    // el tenant lo define su propio JWT al iniciar sesión (no lo pisamos).
    final tenant = uri.queryParameters['tenant'];
    if (tenant != null &&
        tenant.isNotEmpty &&
        authProvider.status == AuthStatus.authenticated &&
        authProvider.organizationId != tenant) {
      await authProvider.selectOrganization(tenant);
    }

    router.go(location);
  }

  /// Mapea `campeando://application/<id>` -> `/applications/<id>`
  /// (la pantalla de detalle del participante con el comprobante).
  String? _locationFor(Uri uri) {
    if (uri.scheme != 'campeando') return null;
    if (uri.host == 'application' && uri.pathSegments.isNotEmpty) {
      return '/applications/${uri.pathSegments.first}';
    }
    return null;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
