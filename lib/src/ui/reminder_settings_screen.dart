import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({required this.prayerName, super.key});

  final String prayerName;

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  static const List<int> _minuteOptions = <int>[5, 10, 15, 20, 30, 45, 60];

  late final TextEditingController _customMinutesController;
  final FocusNode _customMinutesFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _customMinutesController = TextEditingController();
  }

  @override
  void dispose() {
    _customMinutesController.dispose();
    _customMinutesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final setting = controller.reminderFor(widget.prayerName);
        final canEditBeforeMinutes = setting.notifyBefore;

        if (!_customMinutesFocus.hasFocus) {
          final currentText = _customMinutesController.text.trim();
          final expected = setting.minutesBefore.toString();
          if (currentText != expected) {
            _customMinutesController.text = expected;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.reminderScreenTitle(widget.prayerName)),
          ),
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
                        context.l10n.reminderTypeTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: Text(context.l10n.onTime),
                            selected: setting.notifyOnTime,
                            onSelected: (value) =>
                                controller.updateReminderSetting(
                                  prayer: widget.prayerName,
                                  notifyOnTime: value,
                                ),
                          ),
                          FilterChip(
                            label: Text(context.l10n.before),
                            selected: setting.notifyBefore,
                            onSelected: (value) =>
                                controller.updateReminderSetting(
                                  prayer: widget.prayerName,
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
                        context.l10n.remindBeforePrayerTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _minuteOptions
                            .map(
                              (option) => ChoiceChip(
                                label: Text(context.l10n.minutesValue(option)),
                                selected: setting.minutesBefore == option,
                                onSelected: canEditBeforeMinutes
                                    ? (_) => controller.updateReminderSetting(
                                        prayer: widget.prayerName,
                                        minutesBefore: option,
                                      )
                                    : null,
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customMinutesController,
                              focusNode: _customMinutesFocus,
                              enabled: canEditBeforeMinutes,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: context.l10n.customMinutes,
                                hintText: context.l10n.customMinutesHint,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: canEditBeforeMinutes
                                ? () => _saveCustomMinutes(
                                    context: context,
                                    controller: controller,
                                  )
                                : null,
                            child: Text(context.l10n.save),
                          ),
                        ],
                      ),
                      if (!setting.notifyBefore)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(context.l10n.enableBeforeToSelectMinutes),
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

  Future<void> _saveCustomMinutes({
    required BuildContext context,
    required PrayerAppController controller,
  }) async {
    final parsed = int.tryParse(_customMinutesController.text.trim());
    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.enterValidPositiveNumber)),
      );
      return;
    }
    if (parsed > 240) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.useValueUpTo240)),
      );
      return;
    }
    await controller.updateReminderSetting(
      prayer: widget.prayerName,
      minutesBefore: parsed,
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.customMinutesSaved)));
  }
}
