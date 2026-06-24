import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';
import '../widgets/metric_card_widget.dart';

class StaffDashboardScreen extends StatefulWidget {
  final String eventId;

  const StaffDashboardScreen({super.key, required this.eventId});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadMetrics(widget.eventId);
    });
  }

  Future<void> _refresh() {
    return context.read<DashboardProvider>().loadMetrics(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métricas del Evento'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.metrics == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final metrics = provider.metrics;
          if (metrics == null) {
            return const Center(child: Text('Sin datos de métricas.'));
          }

          final cards = [
            MetricCardWidget(
              icon: Icons.event_seat,
              label: 'Capacidad total',
              value: '${metrics.totalCapacity}',
            ),
            MetricCardWidget(
              icon: Icons.how_to_reg,
              label: 'Asistentes ingresados',
              value: '${metrics.checkedInCount}',
              color: Colors.green,
            ),
            MetricCardWidget(
              icon: Icons.restaurant,
              label: 'Raciones consumidas',
              value: '${metrics.rationsConsumed}',
              color: Colors.orange,
            ),
            MetricCardWidget(
              icon: Icons.hourglass_bottom,
              label: 'Cupos disponibles',
              value: '${metrics.availableSpots}',
              color: Colors.blueGrey,
            ),
          ];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // En pantallas anchas (desktop/tablet) mostramos las 4 métricas
                // en una sola fila; en móvil, una cuadrícula 2x2.
                final isWide = constraints.maxWidth >= 700;
                final crossAxisCount = isWide ? 4 : 2;
                final childAspectRatio = isWide ? 1.25 : 1.05;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: childAspectRatio,
                              children: cards,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => context.push(
                                '/confirmed-participants/${widget.eventId}',
                              ),
                              icon: const Icon(Icons.groups),
                              label: const Text('Participantes confirmados'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
