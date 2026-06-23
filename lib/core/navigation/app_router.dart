import 'package:campeando_frontend/features/access_control/domain/repositories/access_control_repository.dart';
import 'package:campeando_frontend/features/access_control/presentation/providers/access_control_provider.dart';
import 'package:campeando_frontend/features/access_control/presentation/screens/qr_scanner_screen.dart';
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
import 'package:campeando_frontend/features/payment_links/application/payment_link_sharing_service.dart';
import 'package:campeando_frontend/features/payment_links/domain/repositories/payment_links_repository.dart';
import 'package:campeando_frontend/features/payment_links/presentation/providers/payment_links_provider.dart';
import 'package:campeando_frontend/features/payment_links/presentation/screens/send_payment_link_screen.dart';
import 'package:campeando_frontend/features/payment_validation/application/share_deep_link_service.dart';
import 'package:campeando_frontend/features/payment_validation/domain/repositories/payment_validation_repository.dart';
import 'package:campeando_frontend/features/payment_validation/presentation/providers/payment_validation_provider.dart';
import 'package:campeando_frontend/features/payment_validation/presentation/screens/application_detail_screen.dart';
import 'package:campeando_frontend/features/pending_applications/data/models/pending_application_model.dart';
import 'package:campeando_frontend/features/pending_applications/domain/repositories/applications_repository.dart';
import 'package:campeando_frontend/features/pending_applications/presentation/providers/pending_applications_provider.dart';
import 'package:campeando_frontend/features/pending_applications/presentation/screens/pending_applications_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

      // --- Staff operations (MVP features) ---
      GoRoute(
        path: '/scan-qr',
        builder: (context, state) => ChangeNotifierProvider(
          create: (ctx) => AccessControlProvider(
            repository: ctx.read<AccessControlRepository>(),
          ),
          child: const QrScannerScreen(),
        ),
      ),
      GoRoute(
        path: '/pending-applications/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return ChangeNotifierProvider(
            create: (ctx) => PendingApplicationsProvider(
              repository: ctx.read<ApplicationsRepository>(),
            ),
            child: PendingApplicationsScreen(
              tenantId: authProvider.organizationId ?? '',
              eventId: eventId,
            ),
          );
        },
      ),
      GoRoute(
        path: '/applications/:appId',
        builder: (context, state) {
          final appId = state.pathParameters['appId']!;
          final extra = state.extra;
          final application = extra is PendingApplicationModel ? extra : null;
          return ChangeNotifierProvider(
            create: (ctx) => PaymentValidationProvider(
              repository: ctx.read<PaymentValidationRepository>(),
              shareService: ctx.read<ShareDeepLinkService>(),
            ),
            child: ApplicationDetailScreen(
              applicationId: appId,
              applicantName: application?.applicantName ?? 'Postulante',
            ),
          );
        },
        routes: [
          GoRoute(
            path: 'payment-link',
            builder: (context, state) {
              final appId = state.pathParameters['appId']!;
              final extra = state.extra;
              final applicantName = extra is String ? extra : 'Postulante';
              return ChangeNotifierProvider(
                create: (ctx) => PaymentLinksProvider(
                  repository: ctx.read<PaymentLinksRepository>(),
                  sharingService: ctx.read<PaymentLinkSharingService>(),
                ),
                child: SendPaymentLinkScreen(
                  applicationId: appId,
                  applicantName: applicantName,
                  amountToPay: 0,
                ),
              );
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (authProvider.status == AuthStatus.initial) {
        return null;
      }

      final path = state.uri.path;
      final isAuthPath = path == '/login' || path == '/register';
      final isPublicPath = path.startsWith('/events');

      // 1. Allow everyone to access public routes or login/register
      if (isAuthPath || isPublicPath) {
        if (authProvider.status == AuthStatus.authenticated && isAuthPath) {
          return '/';
        }
        return null;
      }

      // 2. If not logged in and trying to access private route, go to login
      if (authProvider.status == AuthStatus.unauthenticated) {
        return '/login';
      }

      // 3. If logged in but no organization, force selection (except if already there)
      if (authProvider.status == AuthStatus.authenticated) {
        if (authProvider.organizationId == null &&
            path != '/organization-selector' &&
            path != '/create-organization') {
          return '/organization-selector';
        }
      }

      return null;
    },
  );
}
