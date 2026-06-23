import '../../domain/repositories/access_control_repository.dart';
import 'datasources/access_control_remote_datasource.dart';
import 'models/qr_validation_response_model.dart';

class AccessControlRepositoryImpl implements AccessControlRepository {
  final AccessControlRemoteDatasource remoteDatasource;

  AccessControlRepositoryImpl({required this.remoteDatasource});

  @override
  Future<QrValidationResponseModel> validateQr(String payload) async {
    return await remoteDatasource.validateQr(payload);
  }
}
