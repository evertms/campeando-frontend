import '../../domain/repositories/payment_links_repository.dart';
import '../datasources/payment_links_remote_datasource.dart';

class PaymentLinksRepositoryImpl implements PaymentLinksRepository {
  final PaymentLinksRemoteDatasource remoteDatasource;

  PaymentLinksRepositoryImpl({required this.remoteDatasource});

  @override
  Future<String> generatePaymentLink(String applicationId) async {
    return await remoteDatasource.generatePaymentLink(applicationId);
  }
}
