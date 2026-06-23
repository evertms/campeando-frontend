import 'package:campeando_frontend/core/data/api_client.dart';
import 'package:campeando_frontend/features/registration/data/models/registration_request_models.dart';

abstract class RegistrationRemoteDatasource {
  Future<void> requestOtp({required String eventId, required RequestOtpRequest request});
  Future<void> verifyOtp({required String eventId, required VerifyOtpRequest request});
  Future<String> submitRegistration({required String eventId, required SubmitRegistrationRequest request});
}

class RegistrationRemoteDatasourceImpl implements RegistrationRemoteDatasource {
  final ApiClient apiClient;

  RegistrationRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<void> requestOtp({required String eventId, required RequestOtpRequest request}) async {
    await apiClient.post(
      '/api/registration/$eventId/request-otp',
      body: request.toJson(),
    );
  }

  @override
  Future<void> verifyOtp({required String eventId, required VerifyOtpRequest request}) async {
    // According to the spec, this endpoint returns 200 OK on success.
    // The ApiClient will throw an exception for non-2xx codes.
    await apiClient.post(
      '/api/registration/$eventId/verify-otp',
      body: request.toJson(),
    );
  }

  @override
  Future<String> submitRegistration({required String eventId, required SubmitRegistrationRequest request}) async {
    final response = await apiClient.post(
      '/api/registration/$eventId/submit',
      body: request.toJson(),
    );
    // El backend responde { "orderId": "<guid>" }; lo usamos para asociar el
    // comprobante de pago subido en el registro público.
    return response['orderId'] as String;
  }
}
