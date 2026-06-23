import '../../../../core/data/api_client.dart';

abstract class PaymentValidationRemoteDatasource {
  Future<String> uploadReceipt(String applicationId, String base64Image);
}

class PaymentValidationRemoteDatasourceImpl
    implements PaymentValidationRemoteDatasource {
  final ApiClient apiClient;

  PaymentValidationRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<String> uploadReceipt(String applicationId, String base64Image) async {
    final response = await apiClient.post(
      '/payments/upload-receipt',
      body: {'applicationId': applicationId, 'fileContentBase64': base64Image},
    );
    return response['receiptUrl'] as String;
  }
}
