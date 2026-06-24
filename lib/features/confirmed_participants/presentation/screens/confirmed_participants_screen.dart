import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/confirmed_participants_provider.dart';

class ConfirmedParticipantsScreen extends StatefulWidget {
  final String eventId;

  const ConfirmedParticipantsScreen({super.key, required this.eventId});

  @override
  State<ConfirmedParticipantsScreen> createState() =>
      _ConfirmedParticipantsScreenState();
}

class _ConfirmedParticipantsScreenState
    extends State<ConfirmedParticipantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfirmedParticipantsProvider>().loadParticipants(
        widget.eventId,
      );
    });
  }

  Future<void> _refresh() {
    return context.read<ConfirmedParticipantsProvider>().loadParticipants(
      widget.eventId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participantes confirmados'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: Consumer<ConfirmedParticipantsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.participants.isEmpty) {
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

          if (provider.participants.isEmpty) {
            return const Center(
              child: Text('No hay participantes confirmados todavía.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: provider.participants.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = provider.participants[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(p.fullName),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${p.rationsConsumed}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        'Raciones consumidas',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
