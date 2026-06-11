import 'package:campeando_frontend/features/events/data/models/event_detail_model.dart';
import 'package:campeando_frontend/features/events/domain/repositories/event_repository.dart';
import 'package:flutter/material.dart';
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
              body: Center(child: Text('Error al cargar el evento: ${snapshot.error}')),
            );
          }
          final event = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(event.name),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _InfoTile(icon: Icons.calendar_today, title: 'Fecha de inicio', subtitle: '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}'),
                    _InfoTile(icon: Icons.calendar_today_outlined, title: 'Fecha de fin', subtitle: '${event.endDate.day}/${event.endDate.month}/${event.endDate.year}'),
                    _InfoTile(icon: Icons.people, title: 'Capacidad máxima', subtitle: '${event.maxCapacity} personas'),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Aquí iría una descripción más detallada del evento si la API la proveyera. Por ahora, mostramos los datos clave disponibles.",
                      ),
                    )
                  ],
                ),
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

  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
