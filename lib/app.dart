import 'package:campeando_frontend/core/data/api_client.dart';
import 'package:campeando_frontend/core/navigation/app_router.dart';
import 'package:campeando_frontend/features/events/data/datasources/event_remote_datasource.dart';
import 'package:campeando_frontend/features/events/data/repositories/event_repository_impl.dart';
import 'package:campeando_frontend/features/events/domain/repositories/event_repository.dart';
import 'package:campeando_frontend/features/registration/data/datasources/registration_remote_datasource.dart';
import 'package:campeando_frontend/features/registration/data/repositories/registration_repository_impl.dart';
import 'package:campeando_frontend/features/registration/domain/repositories/registration_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:campeando_system_design/design_system.dart';

class CampeandoApp extends StatelessWidget {
  const CampeandoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _getProviders(),
      child: MaterialApp.router(
        title: 'Campeando',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme.lightTheme,
      ),
    );
  }

  List<SingleChildWidget> _getProviders() {
    // Infrastructure
    final apiClient = ApiClient();

    // Datasources
    final eventRemoteDatasource = EventRemoteDatasourceImpl(
      apiClient: apiClient,
    );
    final registrationRemoteDatasource = RegistrationRemoteDatasourceImpl(
      apiClient: apiClient,
    );

    // Repositories
    final eventRepository = EventRepositoryImpl(
      remoteDatasource: eventRemoteDatasource,
    );
    final registrationRepository = RegistrationRepositoryImpl(
      remoteDatasource: registrationRemoteDatasource,
    );

    return [
      Provider<EventRepository>.value(value: eventRepository),
      Provider<RegistrationRepository>.value(value: registrationRepository),
    ];
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campeando - Demo UI')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const Text(
                'Módulos Implementados',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _MenuTile(
                title: 'Catálogo de Eventos',
                subtitle: 'Listado responsivo (Grid/List) con M3 Cards.',
                icon: Icons.list_alt,
                onTap: () => context.push('/events'),
              ),
              const SizedBox(height: 16),
              _MenuTile(
                title: 'Detalle de Evento (WIP)',
                subtitle: 'Flujo de registro con OTP en desarrollo.',
                icon: Icons.event_note,
                onTap: () {
                  // Hardcoded eventId for now, this will come from the catalog later
                  const String mockEventId =
                      "3fa85f64-5717-4562-b3fc-2c963f66afa6";
                  context.push('/events/$mockEventId');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
