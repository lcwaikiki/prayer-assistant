import 'package:flutter/material.dart';

import '../l10n/tesbihat_localizations.dart';
import '../models/item_group.dart';

enum DeleteGroupBeadsAction {
  keepBeads,
  deleteBeads,
}

/// Displays a confirmation dialog when deleting a bead group.
///
/// If [memberCount] is 0, presents a simple delete confirmation.
/// If [memberCount] > 0, presents choices to either keep member beads as
/// individual beads, or delete the beads along with the group.
Future<DeleteGroupBeadsAction?> showDeleteGroupConfirmationDialog(
  BuildContext context, {
  required ItemGroup group,
  required int memberCount,
}) async {
  final l10n = context.tesbihatL10n;
  final theme = Theme.of(context);

  if (memberCount == 0) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteGroup),
        content: Text(l10n.deleteGroupConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            key: const Key('confirm_delete_group_button'),
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    return confirmed == true ? DeleteGroupBeadsAction.deleteBeads : null;
  }

  return showDialog<DeleteGroupBeadsAction>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteGroup),
      content: Text(
        l10n.deleteGroupWithBeadsMessage(group.title, memberCount.toString()),
      ),
      actions: [
        TextButton(
          key: const Key('cancel_delete_group_button'),
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.cancel),
        ),
        FilledButton.tonal(
          key: const Key('keep_beads_button'),
          onPressed: () =>
              Navigator.pop(dialogContext, DeleteGroupBeadsAction.keepBeads),
          child: Text(l10n.deleteGroupKeepBeadsAction),
        ),
        FilledButton(
          key: const Key('delete_beads_button'),
          onPressed: () =>
              Navigator.pop(dialogContext, DeleteGroupBeadsAction.deleteBeads),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: Text(l10n.deleteGroupDeleteBeadsAction),
        ),
      ],
    ),
  );
}

