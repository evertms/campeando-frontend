import '../../data/models/qr_validation_response_model.dart';

abstract class AccessControlRepository {
  Future<QrValidationResponseModel> validateQr(String payload);
}
