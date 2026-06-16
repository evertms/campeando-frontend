import 'package:campeando_frontend/features/auth/presentation/auth_provider.dart';
import 'package:campeando_frontend/features/events/data/models/event_summary_model.dart';
import 'package:campeando_frontend/features/events/domain/repositories/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OrganizationDashboardScreen extends StatefulWidget {
  const OrganizationDashboardScreen({super.key});

  @override
  State<OrganizationDashboardScreen> createState() =>
      _OrganizationDashboardScreenState();
}

class _OrganizationDashboardScreenState
    extends State<OrganizationDashboardScreen> {
  late Future<List<EventSummaryModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
  }

  Future<List<EventSummaryModel>> _loadEvents() async {
    final eventRepo = context.read<EventRepository>();
    final auth = context.read<AuthProvider>();

    final events = await eventRepo.getAllEvents();
    final orgId = auth.organizationId;

    // Filter by organization if needed (assuming API might return all)
    // and sort by startDate (closest first)
    final filteredEvents = events.where((e) => e.organizationId == orgId).toList();
    filteredEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

    return filteredEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Eventos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/organization-selector'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: FutureBuilder<List<EventSummaryModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No has creado eventos todavía.'));
          }

          final events = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                child: ListTile(
                  title: Text(event.name),
                  subtitle: Text(
                    'Inicia: ${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/events/${event.id}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-event'),
        label: const Text('Crear Evento'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
