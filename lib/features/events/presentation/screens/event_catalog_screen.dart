import 'package:flutter/material.dart';

class EventCatalogScreen extends StatelessWidget {
  const EventCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mockEvents = List.generate(
      10,
      (index) => {
        'title': 'Evento Deportivo ${index + 1}',
        'date': '15 de Octubre, 2026',
        'location': 'Estadio Nacional',
        'image': 'https://via.placeholder.com/400x200',
      },
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.medium(
            title: Text('Catálogo de Eventos'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final bool isMobile = constraints.crossAxisExtent < 600;

                if (isMobile) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _EventCard(event: mockEvents[index]),
                      childCount: mockEvents.length,
                    ),
                  );
                } else {
                  return SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400.0,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _EventCard(event: mockEvents[index]),
                      childCount: mockEvents.length,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, String> event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          // Navegación a detalle (se implementará en main.dart o vía argumentos)
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.image, size: 48),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        event['date']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        event['location']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
