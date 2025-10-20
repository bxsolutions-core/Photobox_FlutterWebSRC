import 'package:flutter/foundation.dart';

class Env {
  static late final String apiBase;
  static late final String appBase;
  static late final bool showDebugOverlays;
  static late final bool useFirebaseUpload;

  static const String campaignName = 'DORCO Sleek Event';
  static const String campaignAppName = 'DORCO Sleek Photobooth';
  static const String campaignID = 'DORCO-2025-001';

  static const String qrPrefix = 'dorcoprint';

  static void init() {
    final host = Uri.base.host;
    final path = Uri.base.path;

    if (host.contains('stg') || path.contains('stg')) {
      // STAGING (Plesk)
      apiBase = 'https://eventpro.cheil.rocks/_stg/api/v1';
      appBase = 'https://eventpro.cheil.rocks/_stg/apps';

      showDebugOverlays = true;
      useFirebaseUpload = false;
    } else if (host == 'localhost') {
      // LOCALHOST
      apiBase = 'http://localhost/eventpro.cheil.rocks/api/v1';
      appBase = 'http://localhost/eventpro.cheil.rocks/apps';

      showDebugOverlays = true;
      useFirebaseUpload = false;
    } else {
      // PRODUCTION (Plesk)
      apiBase = 'https://eventpro.cheil.rocks/_/api/v1';
      appBase = 'https://eventpro.cheil.rocks/_/apps';

      showDebugOverlays = false;
      useFirebaseUpload = true;
    }

    debugPrint('Env [apiBase=$apiBase, appBase=$appBase] | path=$path');
  }
}
