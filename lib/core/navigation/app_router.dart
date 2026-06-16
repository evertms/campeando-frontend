import 'package:campeando_frontend/features/auth/presentation/auth_provider.dart';
import 'package:campeando_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:campeando_frontend/features/auth/presentation/screens/register_screen.dart';
import 'package:campeando_frontend/features/events/presentation/screens/create_event_screen.dart';
import 'package:campeando_frontend/features/events/presentation/screens/event_catalog_screen.dart';
import 'package:campeando_frontend/features/events/presentation/screens/event_info_screen.dart';
import 'package:campeando_frontend/features/events/presentation/screens/event_registration_screen.dart';
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
            routes: [
              GoRoute(
                path: 'register',
                builder: (context, state) {
                  final eventId = state.pathParameters['id']!;
                  return EventRegistrationScreen(eventId: eventId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (authProvider.status == AuthStatus.initial) {
        return null;
      }

      final location = state.matchedLocation;
      final loggingIn = location == '/login' || location == '/register';
      final isPublicRoute = location.startsWith('/events');

      // 1. Allow everyone to access public routes or login/register
      if (loggingIn || isPublicRoute) {
        // If already logged in and trying to go to login/register, go to home
        if (authProvider.status == AuthStatus.authenticated && loggingIn) {
          return '/';
        }
        return null;
      }

      // 2. If not logged in and not a public route, go to login
      if (authProvider.status == AuthStatus.unauthenticated) {
        return '/login';
      }

      // 3. If logged in but no organization, force selection (except if already there)
      if (authProvider.status == AuthStatus.authenticated) {
        final isSelectingOrg = location == '/organization-selector' ||
            location == '/create-organization';

        if (authProvider.organizationId == null && !isSelectingOrg) {
          return '/organization-selector';
        }
      }

      return null;
    },
  );
}
