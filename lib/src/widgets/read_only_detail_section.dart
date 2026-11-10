import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../tesbihat/models/item.dart';
import '../tesbihat/widgets/audio_speed_bar.dart';
import '../tesbihat/widgets/zoomable_notes_text.dart';

/// Hero header for read-only view displaying title, avatar icon, and badges.
class ReadOnlyHeroHeader extends StatelessWidget {
  const ReadOnlyHeroHeader({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.badges = const [],
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final List<Widget> badges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 28,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: badges,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A styled card container for grouping read-only information sections.
class ReadOnlyCardContainer extends StatelessWidget {
  const ReadOnlyCardContainer({
    super.key,
    required this.title,
    this.icon,
    required this.children,
  });

  final String title;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A concise key-value detail tile without interactive form controls.
class ReadOnlyFieldTile extends StatelessWidget {
  const ReadOnlyFieldTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.customChild,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Widget? customChild;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isHighlighted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (customChild != null)
                  customChild!
                else
                  SelectableText(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isHighlighted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats milliseconds into m:ss format (e.g. 1:05, 0:12).
String formatAudioDurationMs(int durationMs) {
  if (durationMs <= 0) return '0:00';
  final totalSeconds = (durationMs / 1000).round();
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// An audio player card for read-only detail views and audio playback across the app,
/// styled consistently with the beads execution screen player.
class ReadOnlySoundPlayerCard extends StatefulWidget {
  const ReadOnlySoundPlayerCard({
    super.key,
    required this.title,
    this.subtitle,
    this.duration,
    this.speed = 1.0,
    this.onSpeedChanged,
    this.extraDetail,
    required this.isPlaying,
    required this.onPlayPause,
    this.playButtonKey,
    this.toggleControlsKey,
    this.actions = const [],
    this.extraContent,
  });

  final String title;
  final String? subtitle;
  final String? duration;
  final double speed;
  final ValueChanged<double>? onSpeedChanged;
  final String? extraDetail;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final Key? playButtonKey;
  final Key? toggleControlsKey;
  final List<Widget> actions;
  final Widget? extraContent;

  @override
  State<ReadOnlySoundPlayerCard> createState() => _ReadOnlySoundPlayerCardState();
}

class _ReadOnlySoundPlayerCardState extends State<ReadOnlySoundPlayerCard> {
  bool _isSoundControlsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final String speedStr;
    if (widget.speed == widget.speed.roundToDouble()) {
      speedStr = '${widget.speed.toInt()}x';
    } else {
      final fixed2 = widget.speed.toStringAsFixed(2);
      speedStr = fixed2.endsWith('0')
          ? '${widget.speed.toStringAsFixed(1)}x'
          : '${fixed2}x';
    }

    final subtitleParts = <String>[];
    if (widget.subtitle != null && widget.subtitle!.isNotEmpty) {
      subtitleParts.add(widget.subtitle!);
    }
    subtitleParts.add(l10n?.readOnlyPlaybackSpeedLabel(speedStr) ?? '$speedStr speed');
    final subtitleDisplay = subtitleParts.join(' • ');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    key: widget.playButtonKey,
                    onPressed: widget.onPlayPause,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      backgroundColor: widget.isPlaying
                          ? colorScheme.primary
                          : colorScheme.primaryContainer,
                      foregroundColor: widget.isPlaying
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subtitleDisplay.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitleDisplay,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: widget.isPlaying
                                        ? colorScheme.onPrimary.withValues(alpha: 0.8)
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.duration != null &&
                            widget.duration!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            widget.duration!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.isPlaying
                                  ? colorScheme.onPrimary.withValues(alpha: 0.9)
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (widget.onSpeedChanged != null) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    key: widget.toggleControlsKey ??
                        const Key('toggle_sound_controls_button'),
                    onPressed: () {
                      setState(() {
                        _isSoundControlsExpanded = !_isSoundControlsExpanded;
                      });
                    },
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: AnimatedRotation(
                      turns: _isSoundControlsExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                ],
                for (final action in widget.actions) ...[
                  const SizedBox(width: 8),
                  action,
                ],
              ],
            ),
            if (_isSoundControlsExpanded && widget.onSpeedChanged != null) ...[
              const SizedBox(height: 8),
              AudioSpeedBar(
                speed: widget.speed,
                onSpeedChanged: widget.onSpeedChanged!,
              ),
            ],
            if (widget.extraDetail != null && widget.extraDetail!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.extraDetail!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            if (widget.extraContent != null) ...[
              const SizedBox(height: 4),
              widget.extraContent!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A modern circular progress ring and 3-column stats card for beads.
class ReadOnlyCircularProgressCard extends StatelessWidget {
  const ReadOnlyCircularProgressCard({
    super.key,
    required this.currentCount,
    required this.targetCount,
    required this.checkCount,
    required this.vibrationIntensity,
    this.setCount = 0,
    this.title,
  });

  final int currentCount;
  final int targetCount;
  final int checkCount;
  final int vibrationIntensity;
  final int setCount;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final displayTitle =
        title ?? (l10n?.readOnlyProgressAndTarget ?? 'Progress & Target');
    final progressFraction = targetCount > 0
        ? (currentCount / targetCount).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progressFraction * 100).toInt();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.adjust_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  displayTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Radial Progress Indicator
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: progressFraction,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$currentCount / $targetCount',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$percent%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 3-Column Stats Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      label: l10n?.readOnlyStatTarget ?? 'Target',
                      value: '$targetCount',
                      icon: Icons.flag_outlined,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: l10n?.readOnlyStatCheck ?? 'Check',
                      value: '$checkCount',
                      icon: Icons.checklist_rounded,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: l10n?.readOnlyStatVibration ?? 'Vibration',
                      value: '$vibrationIntensity%',
                      icon: Icons.vibration_rounded,
                    ),
                  ),
                  if (setCount > 0) ...[
                    Container(
                      width: 1,
                      height: 28,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    Expanded(
                      child: _StatColumn(
                        label: l10n?.readOnlyStatSets ?? 'Sets',
                        value: '$setCount',
                        icon: Icons.replay_rounded,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// A dedicated timing callout card highlighting prayer-relative offsets or fixed times.
class ReadOnlyTimingHeroCard extends StatelessWidget {
  const ReadOnlyTimingHeroCard({
    super.key,
    required this.timingSummary,
    this.isEnabled = true,
    this.nextOccurrence,
    this.recurrenceText,
  });

  final String timingSummary;
  final bool isEnabled;
  final String? nextOccurrence;
  final String? recurrenceText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: isEnabled
          ? colorScheme.primaryContainer.withValues(alpha: 0.25)
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isEnabled
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isEnabled
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isEnabled ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                size: 24,
                color: isEnabled
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n?.readOnlyReminderSchedule ?? 'Reminder Schedule',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isEnabled
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (isEnabled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n?.readOnlyActive ?? 'Active',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timingSummary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (nextOccurrence != null && nextOccurrence!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          nextOccurrence!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card for multi-line notes with two-finger pinch-to-zoom text scaling and expand toggle.
class ReadOnlyZoomableNotesCard extends StatefulWidget {
  const ReadOnlyZoomableNotesCard({
    super.key,
    required this.notes,
    this.title,
    this.icon = Icons.menu_book_rounded,
    this.initialExpanded = false,
  });

  final String notes;
  final String? title;
  final IconData icon;
  final bool initialExpanded;

  @override
  State<ReadOnlyZoomableNotesCard> createState() =>
      _ReadOnlyZoomableNotesCardState();
}

class _ReadOnlyZoomableNotesCardState extends State<ReadOnlyZoomableNotesCard> {
  late bool _isExpanded = widget.initialExpanded;
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final displayTitle = widget.title ??
        (l10n?.readOnlyNotesAndInvocation ?? 'Notes & Invocation');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.icon,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Pinch to Zoom scale indicator chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pinch_outlined,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n?.readOnlyPinchZoom(_scale.toStringAsFixed(1)) ??
                            'Pinch ${_scale.toStringAsFixed(1)}x',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Expand / Collapse Toggle
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: Icon(
                    _isExpanded
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: _isExpanded
                      ? (l10n?.readOnlyCollapse ?? 'Collapse')
                      : (l10n?.readOnlyExpand ?? 'Expand'),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: BoxConstraints(
                maxHeight: _isExpanded ? 400 : 160,
                minHeight: 60,
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ZoomableNotesText(
                text: widget.notes,
                zoomable: true,
                initialScale: _scale,
                onScaleChanged: (newScale) {
                  setState(() => _scale = newScale);
                },
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A sequence card showing ordered member beads and completion status within a group.
class ReadOnlyGroupSequenceCard extends StatelessWidget {
  const ReadOnlyGroupSequenceCard({
    super.key,
    required this.members,
    this.onMemberTap,
    this.title,
  });

  final List<Item> members;
  final ValueChanged<Item>? onMemberTap;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final displayTitle = title ?? (l10n?.beadsGroupMembers ?? 'Group Members');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_list_numbered_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '$displayTitle (${members.length})',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n?.readOnlyNoBeadsInGroup ?? 'No beads in this group',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (var i = 0; i < members.length; i++) ...[
                _GroupMemberTile(
                  index: i + 1,
                  item: members[i],
                  onTap: onMemberTap != null ? () => onMemberTap!(members[i]) : null,
                ),
                if (i < members.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}

class _GroupMemberTile extends StatelessWidget {
  const _GroupMemberTile({
    required this.index,
    required this.item,
    this.onTap,
  });

  final int index;
  final Item item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = item.count > 0 && item.currentProgress >= item.count;
    final isInProgress = item.currentProgress > 0 && !isCompleted;
    final fraction = item.count > 0
        ? (item.currentProgress / item.count).clamp(0.0, 1.0)
        : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: colorScheme.onPrimaryContainer,
                    )
                  : Text(
                      '$index',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.notes.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.notes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.currentProgress} / ${item.count}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
                if (isInProgress) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A preview pill list for quick notification snooze actions.
class ReadOnlySnoozePreviewCard extends StatelessWidget {
  const ReadOnlySnoozePreviewCard({
    super.key,
    this.intervals = const [5, 10, 15],
  });

  final List<int> intervals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.snooze_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.readOnlyNotificationSnoozeOptions ??
                      'Notification Snooze Options',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: intervals.map((m) {
                return Chip(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  side: BorderSide.none,
                  avatar: Icon(
                    Icons.snooze,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    l10n?.readOnlySnoozeMinutes(m.toString()) ?? '+$m min',
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A floating bottom action bar providing a primary filled button and secondary outlined edit button.
class ReadOnlyBottomActionBar extends StatelessWidget {
  const ReadOnlyBottomActionBar({
    super.key,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.secondaryIcon,
    required this.onSecondaryPressed,
    this.primaryKey,
    this.secondaryKey,
  });

  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimaryPressed;
  final String secondaryLabel;
  final IconData secondaryIcon;
  final VoidCallback onSecondaryPressed;
  final Key? primaryKey;
  final Key? secondaryKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: FilledButton.icon(
                key: primaryKey,
                onPressed: onPrimaryPressed,
                icon: Icon(primaryIcon, size: 20),
                label: Text(
                  primaryLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                key: secondaryKey,
                onPressed: onSecondaryPressed,
                icon: Icon(secondaryIcon, size: 18),
                label: Text(secondaryLabel),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
