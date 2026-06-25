import '../../../../core/config.dart';
import '../../../../core/data/api_client.dart';
import '../../../pending_applications/data/models/pending_application_model.dart';

abstract class PaymentValidationRemoteDatasource {
  Future<String> uploadReceipt(String applicationId, String base64Image);
  Future<void> updateOrderStatus(String orderId, String status);
  Future<PendingApplicationModel> getApplication(String applicationId);
}

class PaymentValidationRemoteDatasourceImpl
    implements PaymentValidationRemoteDatasource {
  final ApiClient apiClient;

  PaymentValidationRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<PendingApplicationModel> getApplication(String applicationId) async {
    // Endpoint público ([AllowAnonymous]); no depende de la sesión.
    final response = await apiClient.get('/api/applications/$applicationId');
    final json = Map<String, dynamic>.from(response as Map);

    // El comprobante puede venir como ruta relativa; la resolvemos contra el
    // host de la API para que Image.network la cargue (igual que uploadReceipt).
    final receipt = json['receiptFileUrl'] as String?;
    if (receipt != null && receipt.startsWith('/')) {
      json['receiptFileUrl'] = '$baseUrl$receipt';
    }
    return PendingApplicationModel.fromJson(json);
  }

  @override
  Future<String> uploadReceipt(String applicationId, String base64Image) async {
    final response = await apiClient.post(
      '/api/payments/upload-receipt',
      body: {'applicationId': applicationId, 'fileContentBase64': base64Image},
    );
    final receiptUrl = response['receiptUrl'] as String;

    // El backend devuelve una ruta relativa (ej. /receipts/{id}.png); la
    // resolvemos contra el host de la API para que Image.network la cargue.
    if (receiptUrl.startsWith('/')) {
      return '$baseUrl$receiptUrl';
    }
    return receiptUrl;
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    // El backend acepta el estado como string (ej. "Confirmed" / "Rejected").
    await apiClient.patch(
      '/api/registration/orders/$orderId/status',
      body: {'status': status},
    );
  }
}
