import 'package:flutter/services.dart' show appFlavor;

/// The two builds of the app, each with its own Firebase project.
///
/// The environment comes from the Flutter flavor (`--flavor dev|prod`). Without
/// a flavor it is development on purpose: forgetting it never touches
/// production data.
enum AppEnvironment {
  development(
    flavor: 'dev',
    name: 'Nombra Dev',
    applicationId: 'com.jujeme.nombra.dev',
  ),
  production(
    flavor: 'prod',
    name: 'Nombra',
    applicationId: 'com.jujeme.nombra',
  );

  const AppEnvironment({
    required this.flavor,
    required this.name,
    required this.applicationId,
  });

  final String flavor;
  final String name;
  final String applicationId;

  bool get isProduction => this == production;

  /// Resolves a flavor name; anything unknown (or null) is development.
  static AppEnvironment fromFlavor(String? flavor) =>
      flavor == production.flavor ? production : development;

  static AppEnvironment get current => fromFlavor(appFlavor);
}
