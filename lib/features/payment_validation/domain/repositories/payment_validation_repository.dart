abstract class PaymentValidationRepository {
  Future<String> uploadReceipt(String applicationId, String base64Image);
  Future<void> acceptApplication(String orderId);
  Future<void> rejectApplication(String orderId);
}
