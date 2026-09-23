import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

/// What parts of a backup the user chose to restore.
class RestoreSelection {
  const RestoreSelection({required this.data, required this.preferences});

  final bool data;
  final bool preferences;
}

/// Asks what to restore from a backup before applying it. Returns null when
/// the user cancels. Both options are selected by default.
Future<RestoreSelection?> showRestoreOptionsDialog(BuildContext context) {
  var restoreData = true;
  var restorePreferences = true;
  return showDialog<RestoreSelection>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final canRestore = restoreData || restorePreferences;
          return AlertDialog(
            title: Text(context.l10n.restoreOptionsTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: restoreData,
                  onChanged: (value) =>
                      setState(() => restoreData = value ?? false),
                  title: Text(context.l10n.restoreOptionsData),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: restorePreferences,
                  onChanged: (value) =>
                      setState(() => restorePreferences = value ?? false),
                  title: Text(context.l10n.restoreOptionsPreferences),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: canRestore
                    ? () => Navigator.of(dialogContext).pop(
                          RestoreSelection(
                            data: restoreData,
                            preferences: restorePreferences,
                          ),
                        )
                    : null,
                child: Text(context.l10n.save),
              ),
            ],
          );
        },
      );
    },
  );
}
