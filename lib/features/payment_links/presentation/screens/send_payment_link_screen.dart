import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/payment_links_provider.dart';

class SendPaymentLinkScreen extends StatelessWidget {
  final String applicationId;
  final String applicantName;
  final double amountToPay;

  const SendPaymentLinkScreen({
    super.key,
    required this.applicationId,
    required this.applicantName,
    required this.amountToPay,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar Enlace de Pago')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participante: $applicantName',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Monto a pagar: \$${amountToPay.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Consumer<PaymentLinksProvider>(
              builder: (context, provider, child) {
                if (provider.isGenerating) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    if (provider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => provider.generateAndShareLink(
                          applicationId,
                          applicantName,
                        ),
                        icon: const Icon(Icons.send),
                        label: const Text('Generar y Enviar Enlace'),
                      ),
                    ),
                    if (provider.generatedLink != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Enlace generado:\n${provider.generatedLink}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
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
