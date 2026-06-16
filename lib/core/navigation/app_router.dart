import 'package:campeando_frontend/features/auth/presentation/auth_provider.dart';
import 'package:campeando_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:campeando_frontend/features/auth/presentation/screens/register_screen.dart';
import 'package:campeando_frontend/features/events/presentation/screens/create_event_screen.dart';
import 'package:campeando_frontend/features/events/presentation/screens/event_catalog_screen.dart';
import 'package:campeando_frontend/features/events/presentation/screens/event_info_screen.dart';
import 'package:campeando_frontend/features/organizations/presentation/screens/create_organization_screen.dart';
import 'package:campeando_frontend/features/organizations/presentation/screens/organization_dashboard_screen.dart';
import 'package:campeando_frontend/features/organizations/presentation/screens/organization_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final router = GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          if (authProvider.status == AuthStatus.initial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (authProvider.status == AuthStatus.authenticated &&
              authProvider.organizationId != null) {
            return const OrganizationDashboardScreen();
          }
          // If unauthenticated, redirect logic will take us to /login
          // But for safety, return catalog or login
          return const LoginScreen();
        },
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/organization-selector',
        builder: (context, state) => const OrganizationSelectorScreen(),
      ),
      GoRoute(
        path: '/create-organization',
        builder: (context, state) => const CreateOrganizationScreen(),
      ),
      GoRoute(
        path: '/create-event',
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventCatalogScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final eventId = state.pathParameters['id']!;
              return EventInfoScreen(eventId: eventId);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (authProvider.status == AuthStatus.initial) {
        return null; // Stay on current path or show nothing while initializing
      }

      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isPublicRoute = state.matchedLocation.startsWith('/events');

      if (authProvider.status == AuthStatus.unauthenticated) {
        if (loggingIn || isPublicRoute) {
          return null;
        }
        return '/login';
      }

      if (authProvider.status == AuthStatus.authenticated) {
        if (loggingIn) {
          return '/';
        }

        final isSelectingOrg = state.matchedLocation == '/organization-selector' ||
            state.matchedLocation == '/create-organization';

        // If has org and is in selection, go to home
        if (authProvider.organizationId != null && isSelectingOrg) {
          return '/';
        }

        // Mandatory organization selection if NOT at selection screens
        if (authProvider.organizationId == null && !isSelectingOrg) {
          return '/organization-selector';
        }
      }

      return null;
    },
  );
}
