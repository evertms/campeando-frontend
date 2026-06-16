abstract class OrganizationRepository {
  Future<List<dynamic>> getAllOrganizations();
  Future<dynamic> getOrganizationById(String id);
  Future<void> createOrganization(String name, String? qrPaymentImageUrl);
}
