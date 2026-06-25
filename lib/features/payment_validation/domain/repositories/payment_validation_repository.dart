import 'package:campeando_frontend/features/pending_applications/data/models/pending_application_model.dart';

abstract class PaymentValidationRepository {
  Future<String> uploadReceipt(String applicationId, String base64Image);
  Future<void> acceptApplication(String orderId);
  Future<void> rejectApplication(String orderId);

  /// Trae una postulación por id (GET /api/applications/{id}). Se usa cuando el
  /// detalle se abre por deep link y no llega el modelo por `extra`.
  Future<PendingApplicationModel> getApplication(String applicationId);
}
