// Local Android build: wraps `flutter build apk|appbundle` with the flavors, upload-key signing and file naming.
//
//   dart run scripts/build.dart [--flavor dev|prod] [--aab] [--upload]
//
// Output: builds/<filePrefix>-<flavor>-v<version>-<code>-<yyyyMMdd>.apk|aab. With --upload the file is also copied to
// `driveDir` (build.config.json). The prod flavor must be signed: it needs the upload key properties file
// (storeFile, storePassword, keyAlias, keyPassword), which is never versioned.
import 'dart:convert';
import 'dart:io';

Never _fail(String message) {
  stderr.writeln('build: $message');
  exit(1);
}

String _expandHome(String path) {
  if (!path.startsWith('~')) return path;
  final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
  return home + path.substring(1);
}

Map<String, String> _readProperties(String path) {
  final file = File(_expandHome(path));
  if (!file.existsSync()) _fail('signing properties file not found: $path');
  final result = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    final index = trimmed.indexOf('=');
    if (index > 0) {
      result[trimmed.substring(0, index).trim()] = trimmed.substring(index + 1).trim();
    }
  }
  return result;
}

String _pad(int value) => value.toString().padLeft(2, '0');

Future<void> main(List<String> args) async {
  var flavor = 'dev';
  var isBundle = false;
  var shouldUpload = false;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--flavor':
        if (i + 1 >= args.length) _fail('--flavor needs dev or prod');
        flavor = args[++i];
      case '--aab':
        isBundle = true;
      case '--upload':
        shouldUpload = true;
      default:
        _fail('unknown argument: ${args[i]}');
    }
  }
  if (flavor != 'dev' && flavor != 'prod') _fail('flavor must be dev or prod');

  final config = jsonDecode(File('build.config.json').readAsStringSync()) as Map<String, dynamic>;
  final prefix = config['filePrefix'] as String;

  final versionMatch = RegExp(
    r'^version:\s*(\S+?)\+(\d+)\s*$',
    multiLine: true,
  ).firstMatch(File('pubspec.yaml').readAsStringSync());
  if (versionMatch == null) _fail('pubspec.yaml needs "version: x.y.z+code"');
  final version = versionMatch.group(1)!;
  final code = versionMatch.group(2)!;

  final environment = Map<String, String>.from(Platform.environment);
  final keyFile = config['uploadKeyPropertiesFile'] as String?;
  if (flavor == 'prod') {
    if (keyFile == null) {
      _fail('uploadKeyPropertiesFile is required in build.config.json for prod');
    }
    final key = _readProperties(keyFile);
    for (final name in ['storeFile', 'storePassword', 'keyAlias', 'keyPassword']) {
      if (key[name] == null) _fail('$name is missing in $keyFile');
    }
    // Gradle properties through the environment: passwords never show in a command line.
    environment['ORG_GRADLE_PROJECT_UPLOAD_STORE_FILE'] = _expandHome(key['storeFile']!);
    environment['ORG_GRADLE_PROJECT_UPLOAD_STORE_PASSWORD'] = key['storePassword']!;
    environment['ORG_GRADLE_PROJECT_UPLOAD_KEY_ALIAS'] = key['keyAlias']!;
    environment['ORG_GRADLE_PROJECT_UPLOAD_KEY_PASSWORD'] = key['keyPassword']!;
  }

  final target = isBundle ? 'appbundle' : 'apk';
  final process = await Process.start(
    'flutter',
    ['build', target, '--release', '--flavor', flavor],
    environment: environment,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  if (await process.exitCode != 0) _fail('flutter build failed');

  final source = isBundle
      ? 'build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab'
      : 'build/app/outputs/flutter-apk/app-$flavor-release.apk';
  if (!File(source).existsSync()) _fail('expected output not found: $source');

  final now = DateTime.now();
  final date = '${now.year}${_pad(now.month)}${_pad(now.day)}';
  final extension = isBundle ? 'aab' : 'apk';
  final name = '$prefix-$flavor-v$version-$code-$date.$extension';
  Directory('builds').createSync(recursive: true);
  final output = File(source).copySync('builds/$name');
  stdout.writeln('build: ${output.path}');

  if (shouldUpload) {
    final driveDir = config['driveDir'] as String?;
    if (driveDir == null || !Directory(driveDir).existsSync()) {
      _fail('driveDir not found: $driveDir');
    }
    final copy = output.copySync('$driveDir/$name');
    stdout.writeln('build: copied to ${copy.path}');
  }
}
