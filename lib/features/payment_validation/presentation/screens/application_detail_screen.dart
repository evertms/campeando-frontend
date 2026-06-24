import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/auth_provider.dart';
import '../providers/payment_validation_provider.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final String applicationId;
  final String applicantName;

  /// URL absoluta del comprobante (MinIO/S3) provista por el backend, o null.
  final String? receiptUrl;

  const ApplicationDetailScreen({
    super.key,
    required this.applicationId,
    required this.applicantName,
    this.receiptUrl,
  });

  Future<void> _decide(BuildContext context, {required bool accept}) async {
    final provider = context.read<PaymentValidationProvider>();
    final ok = accept
        ? await provider.acceptApplication(applicationId)
        : await provider.rejectApplication(applicationId);

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
            onPressed: () =>
                context.read<PaymentValidationProvider>().shareApplication(
                  applicationId,
                  applicantName: applicantName,
                  tenantId: context.read<AuthProvider>().organizationId,
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              'ID: $applicationId',
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
                      receiptUrl!,
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
            Consumer<PaymentValidationProvider>(
              builder: (context, provider, child) {
                if (provider.isProcessing) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Row(
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
