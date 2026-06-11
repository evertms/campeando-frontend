import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Detalle del Evento'),
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: Icon(
                    Icons.event,
                    size: 80,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isDesktop = constraints.maxWidth > 800;
                
                final content = Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gran Maratón de Verano 2026',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(icon: Icons.calendar_month, text: 'Domingo, 15 de Octubre de 2026'),
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.access_time, text: '07:00 AM - 12:00 PM'),
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.location_on, text: 'Parque Central, Ciudad Principal'),
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.people, text: 'Capacidad máxima: 500 personas'),
                      const SizedBox(height: 24),
                      Text(
                        'Descripción',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Acompañanos en la edición anual de la Gran Maratón de Verano. Este evento busca promover la salud y el bienestar en nuestra comunidad. Habrá categorías para todas las edades y niveles de experiencia.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 40),
                      if (!isDesktop) _buildCTA(context),
                    ],
                  ),
                );

                if (isDesktop) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: content),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Inscripciones',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Las inscripciones aún no están abiertas para este evento.',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      _buildCTA(context, isFullWidth: true),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return content;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context, {bool isFullWidth = false}) {
    final button = FilledButton(
      onPressed: null, // Deshabilitado por ahora
      child: const Text('Registrarse Ahora'),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
