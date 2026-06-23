import 'package:flutter/material.dart';
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

          final available = metrics.totalCapacity - metrics.checkedInCount;
          final availableText = available < 0 ? '0' : '$available';

          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.count(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
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
                  value: availableText,
                  color: Colors.blueGrey,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
