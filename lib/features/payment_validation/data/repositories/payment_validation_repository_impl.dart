import '../../../pending_applications/data/models/pending_application_model.dart';
import '../../domain/repositories/payment_validation_repository.dart';
import '../datasources/payment_validation_remote_datasource.dart';

class PaymentValidationRepositoryImpl implements PaymentValidationRepository {
  final PaymentValidationRemoteDatasource remoteDatasource;

  PaymentValidationRepositoryImpl({required this.remoteDatasource});

  @override
  Future<String> uploadReceipt(String applicationId, String base64Image) async {
    return await remoteDatasource.uploadReceipt(applicationId, base64Image);
  }

  @override
  Future<void> acceptApplication(String orderId) {
    return remoteDatasource.updateOrderStatus(orderId, 'Confirmed');
  }

  @override
  Future<void> rejectApplication(String orderId) {
    return remoteDatasource.updateOrderStatus(orderId, 'Rejected');
  }

  @override
  Future<PendingApplicationModel> getApplication(String applicationId) {
    return remoteDatasource.getApplication(applicationId);
  }
}
