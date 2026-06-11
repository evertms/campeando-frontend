import 'package:campeando_frontend/features/registration/data/models/registration_request_models.dart';

abstract class RegistrationRepository {
  Future<void> requestOtp({required String eventId, required RequestOtpRequest request});
  Future<bool> verifyOtp({required String eventId, required VerifyOtpRequest request});
  Future<void> submitRegistration({required String eventId, required SubmitRegistrationRequest request});
}
