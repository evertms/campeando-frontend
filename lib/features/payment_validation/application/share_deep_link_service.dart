import 'package:share_plus/share_plus.dart';

class ShareDeepLinkService {
  Future<void> shareApplicationLink(String applicationId) async {
    final String deepLink = 'campeando://application/$applicationId';
    await Share.share('Revisa esta postulación en Campeando: $deepLink');
  }
}
