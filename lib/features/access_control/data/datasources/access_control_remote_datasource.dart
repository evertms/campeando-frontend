import '../../../../core/data/api_client.dart';
import '../models/qr_validation_response_model.dart';

abstract class AccessControlRemoteDatasource {
  Future<QrValidationResponseModel> validateQr(String payload);
}

class AccessControlRemoteDatasourceImpl
    implements AccessControlRemoteDatasource {
  final ApiClient apiClient;

  AccessControlRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<QrValidationResponseModel> validateQr(String payload) async {
    final response = await apiClient.post(
      '/events/access/validate-qr',
      body: {'payload': payload},
    );
    return QrValidationResponseModel.fromJson(response);
  }
}
