import '../../../../core/config.dart';
import '../../../../core/data/api_client.dart';

abstract class PaymentValidationRemoteDatasource {
  Future<String> uploadReceipt(String applicationId, String base64Image);
  Future<void> updateOrderStatus(String orderId, String status);
}

class PaymentValidationRemoteDatasourceImpl
    implements PaymentValidationRemoteDatasource {
  final ApiClient apiClient;

  PaymentValidationRemoteDatasourceImpl({required this.apiClient});

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
