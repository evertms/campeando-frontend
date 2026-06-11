import 'package:flutter/material.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/events/presentation/screens/event_catalog_screen.dart';
import 'features/events/presentation/screens/event_detail_screen.dart';

void main() {
  runApp(const CampeandoApp());
}

class CampeandoApp extends StatelessWidget {
  const CampeandoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campeando',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campeando - Demo UI'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const Text(
                'Módulos Implementados',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _MenuTile(
                title: 'Catálogo de Eventos',
                subtitle: 'Listado responsivo (Grid/List) con M3 Cards.',
                icon: Icons.list_alt,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EventCatalogScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _MenuTile(
                title: 'Detalle de Evento',
                subtitle: 'Vista operativa con SliverAppBar y CTA responsivo.',
                icon: Icons.event_note,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EventDetailScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _MenuTile(
                title: 'Ingreso (Login)',
                subtitle: 'Formulario con validación y diseño adaptado.',
                icon: Icons.login,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
