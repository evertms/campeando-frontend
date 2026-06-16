import 'package:campeando_frontend/core/data/api_client.dart';
import 'package:campeando_frontend/features/organizations/domain/repositories/organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final ApiClient apiClient;

  OrganizationRepositoryImpl({required this.apiClient});

  @override
  Future<List<dynamic>> getAllOrganizations() async {
    final response = await apiClient.get('/api/organizations');
    return response as List<dynamic>;
  }

  @override
  Future<dynamic> getOrganizationById(String id) async {
    return await apiClient.get('/api/organizations/$id');
  }

  @override
  Future<void> createOrganization(
    String name,
    String? qrPaymentImageUrl,
  ) async {
    await apiClient.post(
      '/api/organizations',
      body: {'name': name, 'qrPaymentImageUrl': qrPaymentImageUrl},
    );
  }
}
