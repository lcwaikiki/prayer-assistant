import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import '../models/prayer_models.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Preferences')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme mode',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<AppThemePreference>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('System default'),
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
                        title: const Text('Light'),
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
                        title: const Text('Dark'),
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
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Home app bar remaining text',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<AppBarRemainingPlacement>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show in title'),
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
                        title: const Text('Show at right'),
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
                        title: const Text('Show as subtitle'),
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
                        title: const Text('Hide remaining text'),
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
