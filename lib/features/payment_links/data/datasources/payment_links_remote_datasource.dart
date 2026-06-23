import '../../../../core/data/api_client.dart';

abstract class PaymentLinksRemoteDatasource {
  Future<String> generatePaymentLink(String applicationId);
}

class PaymentLinksRemoteDatasourceImpl implements PaymentLinksRemoteDatasource {
  final ApiClient apiClient;

  PaymentLinksRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<String> generatePaymentLink(String applicationId) async {
    final response = await apiClient.post(
      '/api/payments/links/generate',
      body: {'applicationId': applicationId},
    );
    return response['paymentLink'] as String;
  }
}
