import 'package:share_plus/share_plus.dart';

class PaymentLinkSharingService {
  Future<void> shareLink(String url, String applicantName) async {
    final message =
        'Hola $applicantName, aquí tienes tu enlace de pago seguro para el evento: $url';
    await SharePlus.instance.share(ShareParams(text: message));
  }
}
