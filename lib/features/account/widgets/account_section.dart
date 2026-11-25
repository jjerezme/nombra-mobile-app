import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/info_box.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_gateway.dart';
import '../data/backup_sync.dart';
import '../domain/account_models.dart';

/// Settings › Account: sign in with Google and see the state of the automatic backup of the rules.
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isAvailable = ref.watch(authGatewayProvider).isAvailable;
    final user = ref.watch(accountUserProvider).value;
    return AppSection(
      title: l10n.settingsAccount,
      child: AppCard.stack(
        children: [
          if (!isAvailable)
            InfoBox.note(l10n.accountUnavailable)
          else if (user == null)
            const _SignedOut()
          else
            _SignedIn(user: user),
        ],
      ),
    );
  }
}

class _SignedOut extends ConsumerStatefulWidget {
  const _SignedOut();

  @override
  ConsumerState<_SignedOut> createState() => _SignedOutState();
}

class _SignedOutState extends ConsumerState<_SignedOut> {
  bool _isSigningIn = false;

  Future<void> _signIn() async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).accountSignInFailed;
    setState(() => _isSigningIn = true);
    try {
      await ref.read(backupSyncProvider.notifier).signIn();
    } on SignInException catch (error) {
      if (error.failure == SignInFailure.failed) messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppLayout.sectionGap,
      children: [
        Text(l10n.accountBody, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
        FilledButton.icon(
          onPressed: _isSigningIn ? null : _signIn,
          icon: const Icon(Icons.login, size: AppIconSize.base),
          label: Text(l10n.accountSignIn),
        ),
      ],
    );
  }
}

class _SignedIn extends ConsumerWidget {
  const _SignedIn({required this.user});

  final AccountUser user;

  Future<void> _deleteBackup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final isConfirmed = await showConfirmDialog(
      context,
      title: l10n.accountConfirmDeleteTitle,
      message: l10n.accountConfirmDeleteBody,
      confirmLabel: l10n.delete,
    );
    if (!isConfirmed) return;
    try {
      await ref.read(backupSyncProvider.notifier).deleteBackupAndSignOut();
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountDeleteFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final sync = ref.watch(backupSyncProvider);
    final notifier = ref.read(backupSyncProvider.notifier);
    final (statusText, statusIcon, statusColor) = switch (sync.phase) {
      SyncPhase.error => (l10n.accountError, Icons.error_outline, colors.error),
      SyncPhase.upToDate => (l10n.accountUpToDate, Icons.cloud_done_outlined, colors.onSurfaceVariant),
      SyncPhase.off || SyncPhase.syncing => (l10n.accountSyncing, Icons.cloud_sync_outlined, colors.onSurfaceVariant),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppLayout.sectionGap,
      children: [
        Row(
          spacing: AppSpacing.md,
          children: [
            Container(
              width: AppSize.thumb,
              height: AppSize.thumb,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
              child: Text(
                user.label.isEmpty ? '?' : user.label.characters.first.toUpperCase(),
                style: context.text.titleMedium?.copyWith(color: colors.onPrimaryContainer),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.label, style: context.text.bodyLarge, overflow: TextOverflow.ellipsis),
                  if (user.email != null && user.email != user.label)
                    Text(
                      user.email!,
                      style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        Row(
          spacing: AppSpacing.sm,
          children: [
            Icon(statusIcon, size: AppIconSize.base, color: statusColor),
            Expanded(
              child: Text(statusText, style: context.text.bodyMedium?.copyWith(color: statusColor)),
            ),
            if (sync.phase == SyncPhase.error) TextButton(onPressed: notifier.retry, child: Text(l10n.accountRetry)),
          ],
        ),
        ActionRow(
          icon: Icons.logout,
          title: l10n.accountSignOut,
          hint: l10n.accountSignOutHint,
          onTap: notifier.signOut,
        ),
        ActionRow(
          icon: Icons.delete_outline,
          title: l10n.accountDeleteBackup,
          hint: l10n.accountDeleteBackupHint,
          isDestructive: true,
          onTap: () => _deleteBackup(context, ref),
        ),
      ],
    );
  }
}
