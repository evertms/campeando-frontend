import 'package:campeando_frontend/features/auth/presentation/auth_provider.dart';
import 'package:campeando_frontend/features/events/data/models/event_detail_model.dart';
import 'package:campeando_frontend/features/events/domain/repositories/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EventInfoScreen extends StatefulWidget {
  final String eventId;
  const EventInfoScreen({super.key, required this.eventId});

  @override
  State<EventInfoScreen> createState() => _EventInfoScreenState();
}

class _EventInfoScreenState extends State<EventInfoScreen> {
  late Future<EventDetailModel> _eventFuture;

  @override
  void initState() {
    super.initState();
    _eventFuture = context.read<EventRepository>().getEventById(widget.eventId);
  }

  void _copyLink() {
    // Current URI from the window location in web, or construct it
    // Using a relative path for simplicity in constructing the full URL if needed
    final String registrationPath = '/events/${widget.eventId}/register';
    final String fullUrl = Uri.base.origin + registrationPath;

    Clipboard.setData(ClipboardData(text: fullUrl)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enlace de registro copiado al portapapeles'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<EventDetailModel>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text('Error al cargar el evento: ${snapshot.error}'),
              ),
            );
          }
          final event = snapshot.data!;
          final isStaff =
              context.watch<AuthProvider>().status == AuthStatus.authenticated;

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(event.name),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _copyLink,
                    tooltip: 'Copiar enlace de registro',
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  if (event.coverImageUrl != null)
                    Image.network(
                      event.coverImageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  _InfoTile(
                    icon: Icons.calendar_today,
                    title: 'Fecha de inicio',
                    subtitle:
                        '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                  ),
                  _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'Fecha de fin',
                    subtitle:
                        '${event.endDate.day}/${event.endDate.month}/${event.endDate.year}',
                  ),
                  _InfoTile(
                    icon: Icons.people,
                    title: 'Capacidad máxima',
                    subtitle: '${event.maxCapacity} personas',
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.push('/events/${widget.eventId}/register'),
                      icon: const Icon(Icons.app_registration),
                      label: const Text('Registrarse ahora'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton.icon(
                      onPressed: _copyLink,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar enlace para participantes'),
                    ),
                  ),
                  if (isStaff) ...[
                    const Divider(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Operaciones del staff',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: FilledButton.tonalIcon(
                        onPressed: () => context.push('/scan-qr'),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Escanear QR de acceso'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: FilledButton.tonalIcon(
                        onPressed: () => context.push(
                          '/pending-applications/${widget.eventId}',
                        ),
                        icon: const Icon(Icons.pending_actions),
                        label: const Text('Solicitudes pendientes'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            context.push('/dashboard/${widget.eventId}'),
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Métricas del evento'),
                      ),
                    ),
                  ],
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
