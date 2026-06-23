abstract class PaymentValidationRepository {
  Future<String> uploadReceipt(String applicationId, String base64Image);
}
