import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';


import '../calendar/hijri_utils.dart';
import '../controller/prayer_app_controller.dart';
import '../kaza/screens/kaza_tracker_screen.dart';
import '../l10n/l10n.dart';
import '../l10n/locale_options.dart';
import '../models/prayer_models.dart';
import 'location_screen.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.preferencesTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PreferenceSection(
                title: context.l10n.tabLocation,
                subtitle:
                    controller.selectedLocation?.fullName ??
                    context.l10n.locationHelp,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(context.l10n.tabLocation),
                    subtitle: Text(
                      controller.selectedLocation?.fullName ??
                          context.l10n.locationHelp,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: Text(context.l10n.tabLocation),
                          ),
                          body: const LocationScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _PreferenceSection(
                title: context.l10n.languageTitle,
                subtitle: controller.localePreference.nativeLabel(
                  context.l10n.languageSystem,
                ),
                children: AppLocalePreference.values
                    .map(
                      (option) => RadioListTile<AppLocalePreference>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          option.nativeLabel(context.l10n.languageSystem),
                        ),
                        value: option,
                        groupValue: controller.localePreference,
                        onChanged: (value) {
                          if (value != null) {
                            controller.updateLocalePreference(value);
                          }
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 12),
              _PreferenceSection(
                title: context.l10n.themeModeTitle,
                subtitle: _themeSubtitle(context, controller.themePreference),
                children: [
                  RadioListTile<AppThemePreference>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.themeSystem),
                    value: AppThemePreference.system,
                    groupValue: controller.themePreference,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateThemePreference(value);
                      }
                    },
                  ),
                  RadioListTile<AppThemePreference>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.themeLight),
                    value: AppThemePreference.light,
                    groupValue: controller.themePreference,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateThemePreference(value);
                      }
                    },
                  ),
                  RadioListTile<AppThemePreference>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.themeDark),
                    value: AppThemePreference.dark,
                    groupValue: controller.themePreference,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateThemePreference(value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _PreferenceSection(
                title: context.l10n.appBarRemainingTitle,
                subtitle: _appBarRemainingSubtitle(
                  context,
                  controller.appBarRemainingPlacement,
                ),
                children: [
                  RadioListTile<AppBarRemainingPlacement>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.showInTitle),
                    value: AppBarRemainingPlacement.title,
                    groupValue: controller.appBarRemainingPlacement,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateAppBarRemainingPlacement(value);
                      }
                    },
                  ),
                  RadioListTile<AppBarRemainingPlacement>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.showAtRight),
                    value: AppBarRemainingPlacement.trailing,
                    groupValue: controller.appBarRemainingPlacement,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateAppBarRemainingPlacement(value);
                      }
                    },
                  ),
                  RadioListTile<AppBarRemainingPlacement>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.showAsSubtitle),
                    value: AppBarRemainingPlacement.subtitle,
                    groupValue: controller.appBarRemainingPlacement,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateAppBarRemainingPlacement(value);
                      }
                    },
                  ),
                  RadioListTile<AppBarRemainingPlacement>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.hideRemainingText),
                    value: AppBarRemainingPlacement.hidden,
                    groupValue: controller.appBarRemainingPlacement,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateAppBarRemainingPlacement(value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _PreferenceSection(
                title: context.l10n.widgetTextSizeTitle,
                subtitle: _widgetTextSizeSubtitle(
                  context,
                  controller.widgetTextSize,
                ),
                children: [
                  RadioListTile<WidgetTextSize>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.widgetTextSizeExtraSmall),
                    value: WidgetTextSize.extraSmall,
                    groupValue: controller.widgetTextSize,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateWidgetTextSize(value);
                      }
                    },
                  ),
                  RadioListTile<WidgetTextSize>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.widgetTextSizeSmall),
                    value: WidgetTextSize.small,
                    groupValue: controller.widgetTextSize,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateWidgetTextSize(value);
                      }
                    },
                  ),
                  RadioListTile<WidgetTextSize>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.widgetTextSizeMedium),
                    value: WidgetTextSize.medium,
                    groupValue: controller.widgetTextSize,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateWidgetTextSize(value);
                      }
                    },
                  ),
                  RadioListTile<WidgetTextSize>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.widgetTextSizeLarge),
                    value: WidgetTextSize.large,
                    groupValue: controller.widgetTextSize,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateWidgetTextSize(value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _PreferenceSection(
                title: context.l10n.widgetMmssThresholdTitle,
                subtitle: controller.widgetMmssThresholdMinutes == 0
                    ? context.l10n.widgetMmssThresholdNever
                    : context.l10n.widgetMmssThresholdValue(
                        controller.widgetMmssThresholdMinutes,
                      ),
                children: [
                  Slider(
                    value: controller.widgetMmssThresholdMinutes.toDouble(),
                    min: 0,
                    max: 60,
                    divisions: 60,
                    label: context.l10n.widgetMmssThresholdValue(
                      controller.widgetMmssThresholdMinutes,
                    ),
                    onChanged: (value) =>
                        controller.updateWidgetMmssThreshold(value.round()),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _PreferenceSection(
                title: context.l10n.remindersOnOffTitle,
                subtitle: controller.remindersSilenced
                    ? context.l10n.remindersOff
                    : context.l10n.remindersOn,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.remindersOnOffTitle),
                    subtitle: Text(context.l10n.remindersOnOffSubtitle),
                    value: !controller.remindersSilenced,
                    onChanged: (enabled) =>
                        controller.updateRemindersSilenced(!enabled),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.reminderVibrationTitle),
                    subtitle: Text(context.l10n.reminderVibrationSubtitle),
                    value: controller.reminderVibrationEnabled,
                    onChanged: controller.updateReminderVibrationEnabled,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.reminderSoundTitle),
                    subtitle: Text(context.l10n.reminderSoundSubtitle),
                    value: controller.reminderSoundEnabled,
                    onChanged: controller.updateReminderSoundEnabled,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _PreferenceSection(
                title: context.l10n.backupExportTitle,
                subtitle: context.l10n.backupExportSubtitle,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.download_outlined),
                    title: Text(context.l10n.exportBackupJson),
                    onTap: () async {
                      try {
                        final jsonStr = await controller.exportBackupJson();
                        if (context.mounted) {
                          _showExportDialog(
                            context,
                            title: context.l10n.exportBackupJson,
                            content: jsonStr,
                            fileName: 'prayer_assist_backup.json',
                            mimeType: 'application/json',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Export error: $e')),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.upload_outlined),
                    title: Text(context.l10n.restoreBackupJson),
                    onTap: () => _showRestoreDialog(context, controller),
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined),
                    title: Text(context.l10n.exportHolidaysIcs),
                    onTap: () async {
                      try {
                        final l10n = context.l10n;
                        final icsStr = controller.exportIslamicHolidaysIcs(
                          holidayLabel: (key) {
                            return switch (key) {
                              'holiday_islamic_new_year' =>
                                l10n.holiday_islamic_new_year,
                              'holiday_ashura' => l10n.holiday_ashura,
                              'holiday_mawlid' => l10n.holiday_mawlid,
                              'holiday_isra_miraj' => l10n.holiday_isra_miraj,
                              'holiday_laylat_barat' => l10n.holiday_laylat_barat,
                              'holiday_ramadan_first' => l10n.holiday_ramadan_first,
                              'holiday_laylat_qadr' => l10n.holiday_laylat_qadr,
                              'holiday_eid_fitr' => l10n.holiday_eid_fitr,
                              'holiday_arafah' => l10n.holiday_arafah,
                              'holiday_eid_adha' => l10n.holiday_eid_adha,
                              _ => key,
                            };
                          },
                        );
                        if (context.mounted) {
                          _showExportDialog(
                            context,
                            title: context.l10n.exportHolidaysIcs,
                            content: icsStr,
                            fileName: 'islamic_holidays.ics',
                            mimeType: 'text/calendar',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Export error: $e')),
                          );
                        }
                      }
                    },
                  ),

                ],
              ),

            ],
          ),
        );
      },
    );
  }

  void _showRestoreDialog(
    BuildContext context,
    PrayerAppController controller,
  ) {
    final textController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.restoreConfirmTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.restoreConfirmBody),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Paste backup JSON here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final jsonStr = textController.text.trim();
                if (jsonStr.isEmpty) return;
                try {
                  await controller.restoreBackupJson(jsonStr);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.restoreSuccess)),
                    );
                  }
                } catch (_) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(context.l10n.restoreError)),
                    );
                  }
                }
              },
              child: Text(context.l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String fileName,
    required String mimeType,
  }) {
    final bytes = content.length;
    final sizeKb = (bytes / 1024).toStringAsFixed(1);
    final previewText = content.length > 1200
        ? '${content.substring(0, 1200)}\n\n... (${content.length - 1200} characters truncated in preview)'
        : content;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text(title)),
              const SizedBox(width: 8),
              Chip(
                label: Text('$sizeKb KB', style: const TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                width: double.maxFinite,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      previewText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(context.l10n.copyText),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.copiedToClipboard)),
                );
              },
            ),
            FilledButton.icon(
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(context.l10n.shareOrSave),
              onPressed: () async {

                try {
                  final tempDir = Directory.systemTemp;
                  final tempFile = File(path.join(tempDir.path, fileName));
                  await tempFile.writeAsString(content);
                  final box = context.findRenderObject() as RenderBox?;
                  final origin = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;
                  await Share.shareXFiles(
                    [XFile(tempFile.path, mimeType: mimeType)],
                    subject: fileName,
                    sharePositionOrigin: origin,
                  );
                } catch (_) {
                  await Share.share(
                    content,
                    subject: fileName,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

}



class _PreferenceSection extends StatelessWidget {
  const _PreferenceSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

String _themeSubtitle(BuildContext context, AppThemePreference preference) {
  final l10n = context.l10n;
  return switch (preference) {
    AppThemePreference.system => l10n.themeSystem,
    AppThemePreference.light => l10n.themeLight,
    AppThemePreference.dark => l10n.themeDark,
  };
}

String _appBarRemainingSubtitle(
  BuildContext context,
  AppBarRemainingPlacement placement,
) {
  final l10n = context.l10n;
  return switch (placement) {
    AppBarRemainingPlacement.title => l10n.showInTitle,
    AppBarRemainingPlacement.trailing => l10n.showAtRight,
    AppBarRemainingPlacement.subtitle => l10n.showAsSubtitle,
    AppBarRemainingPlacement.hidden => l10n.hideRemainingText,
  };
}

String _widgetTextSizeSubtitle(BuildContext context, WidgetTextSize size) {
  final l10n = context.l10n;
  return switch (size) {
    WidgetTextSize.extraSmall => l10n.widgetTextSizeExtraSmall,
    WidgetTextSize.small => l10n.widgetTextSizeSmall,
    WidgetTextSize.medium => l10n.widgetTextSizeMedium,
    WidgetTextSize.large => l10n.widgetTextSizeLarge,
  };
}
