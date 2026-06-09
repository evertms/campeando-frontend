/// TODO: Entidad base de identidad/autenticación para la plataforma Campeando.
class AccountEntity {
  const AccountEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.tenantId,
    this.roles = const [],
  });

  final String id;
  final String email;
  final String? fullName;
  final String? tenantId;
  final List<String> roles;
}