import 'package:share_plus/share_plus.dart';

class ShareDeepLinkService {
  /// Comparte el detalle del participante (la pantalla donde se ve el
  /// comprobante de pago) mediante un deep link `campeando://application/<id>`.
  Future<void> shareApplicationLink(
    String applicationId, {
    String? applicantName,
    String? tenantId,
  }) async {
    // El tenant del emisor viaja en el link para que el receptor vea la
    // postulación bajo la organización correcta (ver DeepLinkHandler).
    final String tenantQuery = (tenantId != null && tenantId.isNotEmpty)
        ? '?tenant=${Uri.encodeQueryComponent(tenantId)}'
        : '';
    final String deepLink =
        'campeando://application/$applicationId$tenantQuery';
    final String quien = (applicantName != null && applicantName.isNotEmpty)
        ? ' de $applicantName'
        : '';
    await SharePlus.instance.share(
      ShareParams(
        text: 'Revisa el comprobante de pago$quien en Campeando: $deepLink',
      ),
    );
  }
}
