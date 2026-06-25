import 'package:campeando_frontend/features/auth/presentation/auth_provider.dart';
import 'package:campeando_frontend/features/organizations/domain/repositories/organization_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OrganizationSelectorScreen extends StatefulWidget {
  const OrganizationSelectorScreen({super.key});

  @override
  State<OrganizationSelectorScreen> createState() =>
      _OrganizationSelectorScreenState();
}

class _OrganizationSelectorScreenState
    extends State<OrganizationSelectorScreen> {
  late Future<List<dynamic>> _orgsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _orgsFuture = context
          .read<OrganizationRepository>()
          .getAllOrganizations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Organización'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _orgsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final orgs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orgs.length,
            itemBuilder: (context, index) {
              final org = orgs[index];
              return Card(
                child: ListTile(
                  title: Text(org['name'] ?? 'Sin nombre'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectOrg(org['id']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/create-organization');
          _refresh();
        },
        label: const Text('Nueva Organización'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No perteneces a ninguna organización todavía.'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await context.push('/create-organization');
              _refresh();
            },
            child: const Text('Crear mi primera organización'),
          ),
        ],
      ),
    );
  }

  void _selectOrg(String id) async {
    // Recordamos el deep link pendiente (?from=...) antes del await para no
    // usar el context a través de un gap asíncrono.
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    await context.read<AuthProvider>().selectOrganization(id);
    if (!mounted) return;
    // Navegamos explícitamente al destino recordado o al home. `go` reemplaza
    // el stack, así que tanto si llegamos por selección forzada como si
    // abrimos el selector para cambiar de organización terminamos con una sola
    // pantalla de inicio (sin fugas de memoria).
    if (from != null && from.isNotEmpty) {
      context.go(Uri.decodeComponent(from));
    } else {
      context.go('/');
    }
  }
}
