import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/payment_validation_provider.dart';
import '../widgets/receipt_preview_widget.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  // Dummy fields for UI
  final String applicantName;

  const ApplicationDetailScreen({
    super.key,
    required this.applicationId,
    required this.applicantName,
  });

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Postulación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              context.read<PaymentValidationProvider>().shareApplication(
                widget.applicationId,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Postulante: ${widget.applicantName}',
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
            Consumer<PaymentValidationProvider>(
              builder: (context, provider, child) {
                return ReceiptPreviewWidget(imageUrl: provider.receiptUrl);
              },
            ),
            const SizedBox(height: 24),
            Consumer<PaymentValidationProvider>(
              builder: (context, provider, child) {
                if (provider.isUploading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Dummy base64 file content instead of real file picking
                      const dummyBase64 =
                          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
                      await provider.uploadReceipt(
                        widget.applicationId,
                        dummyBase64,
                      );

                      if (provider.error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.error!)),
                        );
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Subir Comprobante'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
