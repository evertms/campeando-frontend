import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/data/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use path-based URLs (no '#') so deep links like
  // /events/:id/register are parsed by the router instead of being
  // ignored by the default hash strategy (which always boots at '/').
  // No-op on non-web platforms.
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  runApp(CampeandoApp(storageService: storageService));
}
