import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../l10n/locale_options.dart';
import '../models/prayer_models.dart';

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
            ],
          ),
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
