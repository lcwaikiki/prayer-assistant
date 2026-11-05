import 'package:flutter/material.dart';

import '../tesbihat/widgets/audio_speed_bar.dart';

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
    subtitleParts.add('$speedStr speed');
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
