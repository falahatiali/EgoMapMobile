import 'dart:io';

Future<bool> launchExternalUrlViaProcess(Uri uri) async {
  if (!Platform.isMacOS && !Platform.isLinux && !Platform.isWindows) {
    return false;
  }

  final url = uri.toString();

  if (url.isEmpty) {
    return false;
  }

  final ProcessResult result;

  if (Platform.isMacOS) {
    result = await Process.run('open', [url]);
  } else if (Platform.isLinux) {
    result = await Process.run('xdg-open', [url]);
  } else {
    result = await Process.run('cmd', ['/c', 'start', '', url], runInShell: true);
  }

  return result.exitCode == 0;
}
