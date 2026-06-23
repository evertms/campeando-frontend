import 'package:campeando_frontend/features/registration/data/datasources/registration_remote_datasource.dart';
import 'package:campeando_frontend/features/registration/data/models/registration_request_models.dart';
import 'package:campeando_frontend/features/registration/domain/repositories/registration_repository.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationRemoteDatasource remoteDatasource;

  RegistrationRepositoryImpl({required this.remoteDatasource});

  @override
  Future<void> requestOtp({required String eventId, required RequestOtpRequest request}) {
    return remoteDatasource.requestOtp(eventId: eventId, request: request);
  }

  @override
  Future<bool> verifyOtp({required String eventId, required VerifyOtpRequest request}) async {
    try {
      await remoteDatasource.verifyOtp(eventId: eventId, request: request);
      return true;
    } catch (e) {
      // Assuming any exception means verification failed.
      // A more robust implementation would inspect the exception type.
      return false;
    }
  }

  @override
  Future<String> submitRegistration({required String eventId, required SubmitRegistrationRequest request}) {
    return remoteDatasource.submitRegistration(eventId: eventId, request: request);
  }
}
