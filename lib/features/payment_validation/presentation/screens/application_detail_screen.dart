import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();
  Uint8List? _localPreview;

  Future<void> _pickAndUploadReceipt() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() => _localPreview = bytes);

    final provider = context.read<PaymentValidationProvider>();
    await provider.uploadReceipt(widget.applicationId, base64Encode(bytes));

    if (!mounted) return;
    final message = provider.error ?? 'Comprobante subido correctamente';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
                if (_localPreview != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _localPreview!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }
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
                    onPressed: _pickAndUploadReceipt,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Subir Comprobante'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(
                  '/applications/${widget.applicationId}/payment-link',
                  extra: widget.applicantName,
                ),
                icon: const Icon(Icons.send),
                label: const Text('Enviar Enlace de Pago'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
