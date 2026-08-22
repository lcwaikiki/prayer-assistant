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

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen>
    with WidgetsBindingObserver {
  static const List<int> _minuteOptions = <int>[5, 10, 15, 20, 30, 45, 60];

  late final TextEditingController _customMinutesController;
  final FocusNode _customMinutesFocus = FocusNode();
  late final TextEditingController _customAfterMinutesController;
  final FocusNode _customAfterMinutesFocus = FocusNode();
  PrayerAppController? _controller;
  bool _customMinutesInitialized = false;
  bool _customMinutesDirty = false;
  bool _customAfterMinutesInitialized = false;
  bool _customAfterMinutesDirty = false;

  @override
  void initState() {
    super.initState();
    _customMinutesController = TextEditingController();
    _customAfterMinutesController = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
    _customMinutesFocus.addListener(_handleCustomMinutesFocusChange);
    _customAfterMinutesFocus.addListener(_handleCustomAfterMinutesFocusChange);
  }

  void _handleCustomMinutesFocusChange() {
    setState(() {});
  }

  void _handleCustomAfterMinutesFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _customMinutesFocus.removeListener(_handleCustomMinutesFocusChange);
    _customAfterMinutesFocus.removeListener(_handleCustomAfterMinutesFocusChange);
    _persistCustomMinutesIfNeeded();
    _persistCustomAfterMinutesIfNeeded();
    _customMinutesController.dispose();
    _customAfterMinutesController.dispose();
    _customMinutesFocus.dispose();
    _customAfterMinutesFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _persistCustomMinutesIfNeeded();
      _persistCustomAfterMinutesIfNeeded();
    }
  }

  void _persistCustomMinutesIfNeeded() {
    if (!_customMinutesDirty) {
      return;
    }
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final setting = controller.reminderFor(widget.prayerName);
    if (!setting.notifyBefore) {
      return;
    }

    final parsed = int.tryParse(_customMinutesController.text.trim());
    if (parsed == null || parsed <= 0 || parsed > 240) {
      return;
    }

    controller.updateReminderSetting(
      prayer: widget.prayerName,
      customMinutesBefore: parsed,
      minutesBefore: parsed,
    );
    _customMinutesDirty = false;
  }

  void _persistCustomAfterMinutesIfNeeded() {
    if (!_customAfterMinutesDirty) {
      return;
    }
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final setting = controller.reminderFor(widget.prayerName);
    if (!setting.notifyAfter) {
      return;
    }

    final parsed = int.tryParse(_customAfterMinutesController.text.trim());
    if (parsed == null || parsed <= 0 || parsed > 240) {
      return;
    }

    controller.updateReminderSetting(
      prayer: widget.prayerName,
      customMinutesAfter: parsed,
      minutesAfter: parsed,
    );
    _customAfterMinutesDirty = false;
  }

  void _initializeCustomMinutesField(int customMinutesBefore) {
    if (_customMinutesInitialized) {
      return;
    }
    _customMinutesController.text = customMinutesBefore.toString();
    _customMinutesInitialized = true;
  }

  void _initializeCustomAfterMinutesField(int customMinutesAfter) {
    if (_customAfterMinutesInitialized) {
      return;
    }
    _customAfterMinutesController.text = customMinutesAfter.toString();
    _customAfterMinutesInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        _controller = controller;
        final setting = controller.reminderFor(widget.prayerName);
        final canEditBeforeMinutes = setting.notifyBefore;
        final canEditAfterMinutes = setting.notifyAfter;
        final colorScheme = Theme.of(context).colorScheme;
        final isCustomMinutes =
            canEditBeforeMinutes &&
            (!_minuteOptions.contains(setting.minutesBefore) ||
                _customMinutesFocus.hasFocus);
        final isCustomAfterMinutes =
            canEditAfterMinutes &&
            (!_minuteOptions.contains(setting.minutesAfter) ||
                _customAfterMinutesFocus.hasFocus);

        _initializeCustomMinutesField(setting.customMinutesBefore);
        _initializeCustomAfterMinutesField(setting.customMinutesAfter);

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              _persistCustomMinutesIfNeeded();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
              context.l10n.reminderScreenTitle(
                context.l10n.prayerNameLabel(widget.prayerName),
              ),
            ),
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
                          context.l10n.reminderAlertTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.reminderAlertSubtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              label: Text(context.l10n.vibrateChip),
                              selected: setting.vibrationEnabled,
                              onSelected: (value) =>
                                  controller.updateReminderSetting(
                                    prayer: widget.prayerName,
                                    vibrationEnabled: value,
                                  ),
                            ),
                            FilterChip(
                              label: Text(context.l10n.soundChip),
                              selected: setting.soundEnabled,
                              onSelected: (value) =>
                                  controller.updateReminderSetting(
                                    prayer: widget.prayerName,
                                    soundEnabled: value,
                                  ),
                            ),
                            FilterChip(
                              label: Text(context.l10n.adhanChip),
                              selected: setting.adhanEnabled,
                              onSelected: setting.soundEnabled
                                  ? (value) => controller
                                      .updateReminderSetting(
                                        prayer: widget.prayerName,
                                        adhanEnabled: value,
                                      )
                                  : null,
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilterChip(
                            label: Text(context.l10n.before),
                            selected: setting.notifyBefore,
                            onSelected: (value) =>
                                controller.updateReminderSetting(
                                  prayer: widget.prayerName,
                                  notifyBefore: value,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.remindBeforePrayerTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ..._minuteOptions
                                .map(
                                  (option) => ChoiceChip(
                                    label: Text(
                                      context.l10n.minutesValue(option),
                                    ),
                                    selected: setting.minutesBefore == option,
                                    onSelected: canEditBeforeMinutes
                                        ? (selected) {
                                            if (selected != true) {
                                              return;
                                            }
                                            setState(() {
                                              _customMinutesDirty = false;
                                            });
                                            controller.updateReminderSetting(
                                              prayer: widget.prayerName,
                                              minutesBefore: option,
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              decoration: BoxDecoration(
                                color: isCustomMinutes
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCustomMinutes
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                  width: isCustomMinutes ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: isCustomMinutes
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l10n.custom,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: isCustomMinutes
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isCustomMinutes
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 44,
                                    child: TextField(
                                      controller: _customMinutesController,
                                      focusNode: _customMinutesFocus,
                                      enabled: canEditBeforeMinutes,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      onChanged: canEditBeforeMinutes
                                          ? (text) {
                                              setState(() {
                                                _customMinutesDirty = true;
                                              });
                                              final parsed = int.tryParse(
                                                text.trim(),
                                              );
                                              if (parsed == null ||
                                                  parsed <= 0 ||
                                                  parsed > 240) {
                                                return;
                                              }
                                              controller.updateReminderSetting(
                                                prayer: widget.prayerName,
                                                customMinutesBefore: parsed,
                                              );
                                            }
                                          : null,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isCustomMinutes
                                                ? colorScheme.onPrimaryContainer
                                                : colorScheme.onSurface,
                                          ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        isCollapsed: true,
                                        labelText: context.l10n.customMinutes,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        hintText:
                                            context.l10n.customMinutesHint,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'min',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isCustomMinutes
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!setting.notifyBefore)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              context.l10n.enableBeforeToSelectMinutes,
                            ),
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilterChip(
                            label: Text(context.l10n.after),
                            selected: setting.notifyAfter,
                            onSelected: (value) =>
                                controller.updateReminderSetting(
                                  prayer: widget.prayerName,
                                  notifyAfter: value,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.remindAfterPrayerTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ..._minuteOptions
                                .map(
                                  (option) => ChoiceChip(
                                    label: Text(
                                      context.l10n.minutesValue(option),
                                    ),
                                    selected: setting.minutesAfter == option,
                                    onSelected: canEditAfterMinutes
                                        ? (selected) {
                                            if (selected != true) {
                                              return;
                                            }
                                            setState(() {
                                              _customAfterMinutesDirty = false;
                                            });
                                            controller.updateReminderSetting(
                                              prayer: widget.prayerName,
                                              minutesAfter: option,
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              decoration: BoxDecoration(
                                color: isCustomAfterMinutes
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCustomAfterMinutes
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                  width: isCustomAfterMinutes ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: isCustomAfterMinutes
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l10n.custom,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: isCustomAfterMinutes
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isCustomAfterMinutes
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 44,
                                    child: TextField(
                                      controller: _customAfterMinutesController,
                                      focusNode: _customAfterMinutesFocus,
                                      enabled: canEditAfterMinutes,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      onChanged: canEditAfterMinutes
                                          ? (text) {
                                              setState(() {
                                                _customAfterMinutesDirty = true;
                                              });
                                              final parsed = int.tryParse(
                                                text.trim(),
                                              );
                                              if (parsed == null ||
                                                  parsed <= 0 ||
                                                  parsed > 240) {
                                                return;
                                              }
                                              controller.updateReminderSetting(
                                                prayer: widget.prayerName,
                                                customMinutesAfter: parsed,
                                              );
                                            }
                                          : null,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isCustomAfterMinutes
                                                ? colorScheme.onPrimaryContainer
                                                : colorScheme.onSurface,
                                          ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        isCollapsed: true,
                                        labelText: context.l10n.customMinutes,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        hintText:
                                            context.l10n.customMinutesHint,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'min',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isCustomAfterMinutes
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!setting.notifyAfter)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              context.l10n.enableAfterToSelectMinutes,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
