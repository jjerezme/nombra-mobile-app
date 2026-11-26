import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/providers.dart';
import '../../account/data/auth_gateway.dart';
import '../domain/dev_info.dart';

/// What only the screen knows: the size and look of the display and the language it is showing.
typedef ScreenFacts = ({String size, String pixelRatio, String textScale, String theme, String appLanguage});

/// Reads [value], or [unknownValue]: a plugin that fails never takes the screen down.
Future<String> _read(Future<Object?> Function() value) async {
  try {
    final result = await value().timeout(const Duration(seconds: 3));
    return result == null || '$result'.isEmpty ? unknownValue : '$result';
  } on Object {
    return unknownValue;
  }
}

Future<List<InfoRow>> _rows(Map<String, Future<Object?> Function()> values) async => [
  for (final entry in values.entries) InfoRow(entry.key, await _read(entry.value)),
];

/// The information part of the developer mode, in the order every app uses (STANDARD.md, "Modo desarrollador").
Future<List<InfoSection>> collectDeveloperInfo(Ref ref, ScreenFacts screen) async {
  final environment = ref.read(appEnvironmentProvider);
  final preferences = ref.read(sharedPreferencesProvider);
  final user = ref.read(accountUserProvider).value;
  Future<PackageInfo> package() => PackageInfo.fromPlatform();
  Future<AndroidDeviceInfo> device() => DeviceInfoPlugin().androidInfo;
  Battery battery() => Battery();
  FirebaseOptions options() => Firebase.app().options;

  return [
    InfoSection(
      'app',
      await _rows({
        'Name': () async => environment.name,
        'Package': () async => (await package()).packageName,
        'Version': () async => '${(await package()).version} (${(await package()).buildNumber})',
        'Flavor': () async => environment.flavor,
        'Build mode': () async => kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug'),
        'Dart': () async => Platform.version.split(' ').first,
      }),
    ),
    InfoSection(
      'device',
      await _rows({
        'Manufacturer': () async => (await device()).manufacturer,
        'Model': () async => (await device()).model,
        'Android': () async {
          final info = await device();
          return '${info.version.release} (SDK ${info.version.sdkInt})';
        },
        'ABIs': () async => (await device()).supportedAbis.join(', '),
        'Physical device': () async => (await device()).isPhysicalDevice,
        'RAM': () async => formatBytes((await device()).physicalRamSize * 1024 * 1024),
      }),
    ),
    InfoSection('display', [
      InfoRow('Size (dp)', screen.size),
      InfoRow('Pixel ratio', screen.pixelRatio),
      InfoRow('Text scale', screen.textScale),
      InfoRow('Theme', screen.theme),
    ]),
    InfoSection(
      'locale',
      await _rows({
        'System locale': () async => Platform.localeName,
        'App language': () async => screen.appLanguage,
        'Time zone': () async => DateTime.now().timeZoneName,
      }),
    ),
    InfoSection(
      'network',
      await _rows({
        'Connection': () async => (await Connectivity().checkConnectivity()).map((result) => result.name).join(', '),
      }),
    ),
    InfoSection(
      'battery',
      await _rows({
        'Level': () async => '${await battery().batteryLevel} %',
        'State': () async => (await battery().batteryState).name,
        'Power saving': () async => await battery().isInBatterySaveMode,
      }),
    ),
    InfoSection(
      'storage',
      await _rows({
        'Total': () async => formatBytes((await device()).totalDiskSize),
        'Free': () async => formatBytes((await device()).freeDiskSize),
        'Stored keys': () async => (preferences.getKeys().toList()..sort()).join(', '),
      }),
    ),
    InfoSection(
      'firebase',
      await _rows({
        'Available': () async => Firebase.apps.isNotEmpty,
        'Project': () async => options().projectId,
        'App ID': () async => options().appId,
        'App Check': () async => environment.isProduction ? 'play integrity' : 'debug',
        'Crashlytics collects': () async => !kDebugMode && Firebase.apps.isNotEmpty,
      }),
    ),
    InfoSection('account', [
      InfoRow('Signed in', '${user != null}'),
      InfoRow('UID', user?.uid ?? unknownValue),
      InfoRow('Email', user?.email ?? unknownValue),
      InfoRow('Name', user?.displayName ?? unknownValue),
    ]),
    InfoSection(
      'notifications',
      await _rows({
        'Permission': () async => (await FileDownloader().permissions.status(PermissionType.notifications)).name,
      }),
    ),
    InfoSection('dependencies', parseDependencies(await rootBundle.loadString('pubspec.yaml'))),
  ];
}
