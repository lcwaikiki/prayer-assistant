import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';

class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({required this.prayerName, super.key});

  final String prayerName;

  static const List<int> _minuteOptions = <int>[5, 10, 15, 20, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final setting = controller.reminderFor(prayerName);
        final canEditBeforeMinutes = setting.notifyBefore;
        return Scaffold(
          appBar: AppBar(title: Text('$prayerName Reminder')),
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
                        'Reminder type (can select both)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('On time'),
                            selected: setting.notifyOnTime,
                            onSelected: (value) =>
                                controller.updateReminderSetting(
                                  prayer: prayerName,
                                  notifyOnTime: value,
                                ),
                          ),
                          FilterChip(
                            label: const Text('Before'),
                            selected: setting.notifyBefore,
                            onSelected: (value) =>
                                controller.updateReminderSetting(
                                  prayer: prayerName,
                                  notifyBefore: value,
                                ),
                          ),
                        ],
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
                        'Remind me before prayer',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _minuteOptions
                            .map(
                              (option) => ChoiceChip(
                                label: Text('$option min'),
                                selected: setting.minutesBefore == option,
                                onSelected: canEditBeforeMinutes
                                    ? (_) => controller.updateReminderSetting(
                                        prayer: prayerName,
                                        minutesBefore: option,
                                      )
                                    : null,
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: canEditBeforeMinutes
                            ? () async {
                                final custom = await _pickCustomMinutes(
                                  context,
                                  setting.minutesBefore,
                                );
                                if (custom != null) {
                                  await controller.updateReminderSetting(
                                    prayer: prayerName,
                                    minutesBefore: custom,
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.edit),
                        label: Text(
                          'Custom minutes (${setting.minutesBefore})',
                        ),
                      ),
                      if (!setting.notifyBefore)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('Enable "Before" to select minutes.'),
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

  Future<int?> _pickCustomMinutes(
    BuildContext context,
    int initialValue,
  ) async {
    final textController = TextEditingController(text: initialValue.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Set custom minutes'),
            content: TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Minutes before prayer',
                hintText: 'e.g. 12',
                errorText: errorText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final parsed = int.tryParse(textController.text.trim());
                  if (parsed == null || parsed <= 0) {
                    setDialogState(
                      () => errorText = 'Enter a valid positive number',
                    );
                    return;
                  }
                  if (parsed > 240) {
                    setDialogState(
                      () => errorText = 'Use a value up to 240 minutes',
                    );
                    return;
                  }
                  Navigator.of(dialogContext).pop(parsed);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    textController.dispose();
    return result;
  }
}
