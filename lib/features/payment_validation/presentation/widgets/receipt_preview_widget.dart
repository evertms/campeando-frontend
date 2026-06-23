import 'package:flutter/material.dart';

class ReceiptPreviewWidget extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;

  const ReceiptPreviewWidget({
    super.key,
    this.imageUrl,
    this.fallbackText = 'No hay comprobante',
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(fallbackText, style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            width: double.infinity,
            color: Colors.red[100],
            child: const Center(child: Icon(Icons.error, color: Colors.red)),
          );
        },
      ),
    );
  }
}
