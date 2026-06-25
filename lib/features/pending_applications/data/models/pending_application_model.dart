class PendingApplicationModel {
  final String id;
  final String applicantName;
  final String paymentStatus;
  final DateTime appliedAt;

  /// URL absoluta del comprobante de pago (MinIO/S3), o null si aún no hay.
  final String? receiptUrl;

  PendingApplicationModel({
    required this.id,
    required this.applicantName,
    required this.paymentStatus,
    required this.appliedAt,
    this.receiptUrl,
  });

  factory PendingApplicationModel.fromJson(Map<String, dynamic> json) {
    return PendingApplicationModel(
      id: json['id'] as String,
      applicantName: json['applicantName'] as String,
      // El listado usa `paymentStatus`; el detalle (GET /api/applications/{id})
      // usa `status`. Aceptamos ambos para reutilizar el modelo.
      paymentStatus:
          (json['paymentStatus'] ?? json['status'] ?? '') as String,
      appliedAt: DateTime.parse(json['appliedAt'] as String),
      receiptUrl: json['receiptFileUrl'] as String?,
    );
  }
}
