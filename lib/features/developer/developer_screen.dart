import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/tokens.dart';
import '../../core/crash_reporting.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/form_parts.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import 'data/developer_info.dart';
import 'domain/dev_info.dart';
import 'widgets/info_section_card.dart';

/// The information of the developer mode; overridden in tests.
final developerInfoProvider = FutureProvider.autoDispose.family<List<InfoSection>, ScreenFacts>(collectDeveloperInfo);

/// Developer mode (development flavor only): the common tools and the technical information, the same in every app.
class DeveloperScreen extends ConsumerWidget {
  const DeveloperScreen({super.key});

  String _title(AppLocalizations l10n, String id) => switch (id) {
    'app' => l10n.developerSectionApp,
    'device' => l10n.developerSectionDevice,
    'display' => l10n.developerSectionDisplay,
    'locale' => l10n.developerSectionLocale,
    'network' => l10n.developerSectionNetwork,
    'battery' => l10n.developerSectionBattery,
    'storage' => l10n.developerSectionStorage,
    'firebase' => l10n.developerSectionFirebase,
    'account' => l10n.developerSectionAccount,
    'notifications' => l10n.developerSectionNotifications,
    _ => l10n.developerSectionDependencies,
  };

  void _toast(BuildContext context, String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final ScreenFacts facts = (
      size: '${media.size.width.round()} × ${media.size.height.round()}',
      pixelRatio: media.devicePixelRatio.toStringAsFixed(2),
      textScale: (media.textScaler.scale(AppFontSize.md) / AppFontSize.md).toStringAsFixed(2),
      theme: Theme.of(context).brightness.name,
      appLanguage: Localizations.localeOf(context).languageCode,
    );
    final sections = ref.watch(developerInfoProvider(facts)).value;

    Future<void> copyReport() async {
      if (sections == null) return;
      await Clipboard.setData(ClipboardData(text: formatReport(sections, (id) => _title(l10n, id))));
      if (context.mounted) _toast(context, l10n.developerReportCopied);
    }

    void sendTestError() {
      try {
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            RedactedError(StateError('Test error from the developer screen')),
            StackTrace.current,
          ),
        );
      } on Object {
        // Without Firebase there is nowhere to send it.
      }
      _toast(context, l10n.developerTestErrorSent);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppPage.paddingWithBack,
          children: [
            ScreenHeader(title: l10n.settingsDeveloper, onBack: () => context.pop()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppLayout.sectionGap,
              children: [
                AppSection(
                  title: l10n.developerCommonTools,
                  child: AppCard.stack(
                    children: [
                      ActionRow(icon: Icons.copy, title: l10n.developerCopyReport, onTap: copyReport),
                      ActionRow(icon: Icons.bug_report_outlined, title: l10n.developerTestError, onTap: sendTestError),
                    ],
                  ),
                ),
                AppSection(
                  title: l10n.developerInformation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppLayout.itemGap,
                    children: [
                      if (sections == null)
                        Text(l10n.developerLoading)
                      else
                        for (final section in sections)
                          InfoSectionCard(title: _title(l10n, section.id), rows: section.rows),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
