import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'external_url_launch_process.dart' if (dart.library.html) 'external_url_launch_noop.dart' as process;

/// Opens [uri] in the platform browser.
///
/// On desktop, prefers the system `open` / `xdg-open` command because the
/// url_launcher pigeon channel can fail after hot reload on macOS.
Future<bool> launchExternalUrl(Uri uri) async {
  if (!kIsWeb) {
    final openedViaProcess = await process.launchExternalUrlViaProcess(uri);

    if (openedViaProcess) {
      return true;
    }
  }

  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on PlatformException catch (error) {
    debugPrint('url_launcher failed: $error');

    if (!kIsWeb) {
      return process.launchExternalUrlViaProcess(uri);
    }

    return false;
  }
}
