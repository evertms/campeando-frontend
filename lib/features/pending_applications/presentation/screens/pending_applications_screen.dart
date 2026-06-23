import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/pending_applications_provider.dart';

class PendingApplicationsScreen extends StatefulWidget {
  final String tenantId;
  final String eventId;

  const PendingApplicationsScreen({
    super.key,
    required this.tenantId,
    required this.eventId,
  });

  @override
  State<PendingApplicationsScreen> createState() =>
      _PendingApplicationsScreenState();
}

class _PendingApplicationsScreenState extends State<PendingApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PendingApplicationsProvider>().fetchPendingApplications(
        widget.tenantId,
        widget.eventId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes Pendientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<PendingApplicationsProvider>()
                  .fetchPendingApplications(widget.tenantId, widget.eventId);
            },
          ),
        ],
      ),
      body: Consumer<PendingApplicationsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                provider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.applications.isEmpty) {
            return const Center(child: Text('No hay solicitudes pendientes.'));
          }

          return ListView.builder(
            itemCount: provider.applications.length,
            itemBuilder: (context, index) {
              final application = provider.applications[index];
              return ListTile(
                title: Text(application.applicantName),
                subtitle: Text('Estado de pago: ${application.paymentStatus}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  '/applications/${application.id}',
                  extra: application,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
