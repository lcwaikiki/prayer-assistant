import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../l10n/tesbihat_localizations.dart';
import '../services/haptic_service.dart';
import '../state/items_notifier.dart';

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});

class ExecutionScreen extends ConsumerStatefulWidget {
  const ExecutionScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<ExecutionScreen> createState() => _ExecutionScreenState();
}

class _ExecutionScreenState extends ConsumerState<ExecutionScreen> {
  void _setWakelock(bool enabled) {
    WakelockPlus.toggle(enable: enabled).catchError((_) {
      // Ignore platform channel errors in unsupported environments.
    });
  }

  @override
  void initState() {
    super.initState();
    _setWakelock(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final item = ref
          .read(itemsNotifierProvider)
          .where((element) => element.id == widget.itemId)
          .firstOrNull;
      if (item != null && item.currentProgress >= item.count) {
        ref.read(itemsNotifierProvider.notifier).resetProgress(widget.itemId);
      }
    });
  }

  @override
  void dispose() {
    _setWakelock(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    final item = ref
        .watch(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.itemNotFound)),
      );
    }

    Future<void> handleTap() async {
      final feedback = ref
          .read(itemsNotifierProvider.notifier)
          .incrementProgress(widget.itemId);
      final haptic = ref.read(hapticServiceProvider);

      if (feedback == TapFeedback.standard) {
        await haptic.standard(intensity: item.vibrationIntensity);
      } else if (feedback == TapFeedback.checkpoint) {
        await haptic.checkpoint(intensity: item.vibrationIntensity);
      }
    }

    Future<void> confirmReset() async {
      final shouldReset = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.resetProgressTitle),
            content: Text(l10n.resetProgressBody),
            actions: [
              TextButton(
                key: const Key('cancel_reset_button'),
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                key: const Key('confirm_reset_button'),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.reset),
              ),
            ],
          );
        },
      );

      if (shouldReset == true) {
        ref.read(itemsNotifierProvider.notifier).resetProgress(widget.itemId);
      }
    }

    Future<void> editProgressAndSetCount() async {
      var progressInput = item.currentProgress.toString();
      var setCountInput = item.setCount.toString();
      String? errorText;

      final result = await showDialog<(int, int)>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(l10n.editProgressAndSetCount),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      key: const Key('progress_edit_field'),
                      initialValue: progressInput,
                      onChanged: (value) => progressInput = value,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.progressCount,
                        hintText: '0 - ${item.count}',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const Key('set_count_edit_field'),
                      initialValue: setCountInput,
                      onChanged: (value) => setCountInput = value,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l10n.setCount),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    key: const Key('cancel_count_set_edit_button'),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    key: const Key('save_count_set_edit_button'),
                    onPressed: () {
                      final progress = int.tryParse(progressInput.trim());
                      final setCount = int.tryParse(setCountInput.trim());
                      if (progress == null) {
                        setState(() {
                          errorText = l10n.validProgressNumber;
                        });
                        return;
                      }
                      if (progress < 0 || progress > item.count) {
                        setState(() {
                          errorText = l10n.progressBetween(item.count);
                        });
                        return;
                      }
                      if (setCount == null || setCount < 0) {
                        setState(() {
                          errorText = l10n.setCountCannotNegative;
                        });
                        return;
                      }
                      Navigator.pop(dialogContext, (progress, setCount));
                    },
                    child: Text(l10n.save),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result != null) {
        final error = ref
            .read(itemsNotifierProvider.notifier)
            .updateProgressAndSetCount(
              id: widget.itemId,
              progress: result.$1,
              setCount: result.$2,
            );
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    }

    final countValue = item.count;
    final maxMinusCount = (item.count - item.currentProgress).clamp(
      0,
      item.count,
    );
    final setCountValue = item.setCount;

    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _TopStatCard(label: l10n.count, value: '$countValue'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TopStatCard(
                    label: l10n.maxMinusCount,
                    value: '$maxMinusCount',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TopStatCard(
                    label: l10n.setCount,
                    value: '$setCountValue',
                    valueKey: const Key('set_count_value_text'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              key: const Key('progress_bar'),
              value: item.count == 0 ? 0 : item.currentProgress / item.count,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              key: const Key('progress_text_long_press_target'),
              onLongPress: editProgressAndSetCount,
              child: Text(
                '${item.currentProgress}',
                key: const Key('progress_text'),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SizedBox.expand(
                child: FilledButton(
                  key: const Key('big_tap_button'),
                  onPressed: item.currentProgress >= item.count
                      ? null
                      : handleTap,
                  child: Text(
                    l10n.tap,
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const Key('reset_button'),
              onPressed: confirmReset,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.reset),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.notes,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              height: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: SingleChildScrollView(
                child: Text(
                  item.notes.isEmpty ? l10n.noNotesAdded : item.notes,
                  key: const Key('notes_bottom_text'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStatCard extends StatelessWidget {
  const _TopStatCard({required this.label, required this.value, this.valueKey});

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              key: valueKey,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
