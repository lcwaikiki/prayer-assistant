import 'package:flutter/material.dart';

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

/// An audio player card for read-only detail views.
class ReadOnlySoundPlayerCard extends StatelessWidget {
  const ReadOnlySoundPlayerCard({
    super.key,
    required this.title,
    this.subtitle,
    this.duration,
    this.speed,
    this.extraDetail,
    required this.isPlaying,
    required this.onPlayPause,
    this.playButtonKey,
  });

  final String title;
  final String? subtitle;
  final String? duration;
  final double? speed;
  final String? extraDetail;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final Key? playButtonKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final details = <String>[];
    if (subtitle != null && subtitle!.isNotEmpty) {
      details.add(subtitle!);
    }
    if (duration != null && duration!.isNotEmpty) {
      details.add(duration!);
    }
    if (speed != null) {
      final String speedStr;
      if (speed == speed!.roundToDouble()) {
        speedStr = '${speed!.toInt()}x';
      } else {
        final fixed2 = speed!.toStringAsFixed(2);
        speedStr =
            fixed2.endsWith('0') ? '${speed!.toStringAsFixed(1)}x' : '${fixed2}x';
      }
      details.add('$speedStr speed');
    }
    if (extraDetail != null && extraDetail!.isNotEmpty) {
      details.add(extraDetail!);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPlaying
            ? colorScheme.primaryContainer.withValues(alpha: 0.35)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlaying
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          FilledButton.tonal(
            key: playButtonKey,
            onPressed: onPlayPause,
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
              backgroundColor: isPlaying
                  ? colorScheme.primary
                  : colorScheme.primaryContainer,
              foregroundColor: isPlaying
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimaryContainer,
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    details.join(' • '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
