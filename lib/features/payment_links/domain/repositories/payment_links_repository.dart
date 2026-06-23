abstract class PaymentLinksRepository {
  Future<String> generatePaymentLink(String applicationId);
}
