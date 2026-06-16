import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/events/presentation/screens/event_catalog_screen.dart';
import '../../features/events/presentation/screens/event_info_screen.dart';
import '../../app.dart'; // For HomeScreen (Demo UI)

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
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
);
