import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/auth_provider.dart';
import '../../../pending_applications/data/models/pending_application_model.dart';
import '../providers/payment_validation_provider.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;

  /// Modelo precargado cuando se navega desde dentro de la app (lista de
  /// postulaciones). Es null cuando se abre por deep link: en ese caso la
  /// pantalla trae los datos por id.
  final PendingApplicationModel? initialApplication;

  const ApplicationDetailScreen({
    super.key,
    required this.applicationId,
    this.initialApplication,
  });

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Tras el primer frame para poder usar el provider del context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaymentValidationProvider>().loadApplication(
        widget.applicationId,
        initial: widget.initialApplication,
      );
    });
  }

  Future<void> _decide(BuildContext context, {required bool accept}) async {
    final provider = context.read<PaymentValidationProvider>();
    final ok = accept
        ? await provider.acceptApplication(widget.applicationId)
        : await provider.rejectApplication(widget.applicationId);

    if (!context.mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? 'Solicitud aceptada. QR enviado por correo.'
                : 'Solicitud rechazada.',
          ),
          backgroundColor: accept ? Colors.green : Colors.red,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Ocurrió un error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Postulación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir comprobante',
            onPressed: () {
              final provider = context.read<PaymentValidationProvider>();
              provider.shareApplication(
                widget.applicationId,
                applicantName: provider.application?.applicantName,
                tenantId: context.read<AuthProvider>().organizationId,
              );
            },
          ),
        ],
      ),
      body: Consumer<PaymentValidationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingApplication) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.loadError != null && provider.application == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      provider.loadError!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => provider.loadApplication(
                        widget.applicationId,
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildContent(context, provider);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PaymentValidationProvider provider,
  ) {
    final applicantName = provider.application?.applicantName ?? 'Postulante';
    final receiptUrl = provider.application?.receiptUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Postulante: $applicantName',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${widget.applicationId}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          const Text(
            'Comprobante de Pago',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: receiptUrl == null
                ? Container(
                    height: 160,
                    alignment: Alignment.center,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Text('Sin comprobante adjunto'),
                  )
                : Image.network(
                    receiptUrl,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      alignment: Alignment.center,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const Text('Sin comprobante adjunto'),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
          if (provider.isProcessing)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _decide(context, accept: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _decide(context, accept: true),
                    icon: const Icon(Icons.check),
                    label: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
