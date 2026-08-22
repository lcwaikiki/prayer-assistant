import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/l10n.dart';
import '../models/supplication_models.dart';

class DailyWisdomCard extends StatelessWidget {
  const DailyWisdomCard({
    super.key,
    required this.wisdom,
  });

  final DailyWisdom wisdom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final localizedText = wisdom.localizedText(lang);
    final isAyah = wisdom.type == 'ayah';

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAyah
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAyah ? Icons.menu_book : Icons.auto_awesome,
                        size: 14,
                        color: isAyah
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAyah
                            ? context.l10n.verseOfTheDay
                            : context.l10n.hadithOfTheDay,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isAyah
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  wisdom.reference,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  wisdom.textAr,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Roboto', // Clean fallback
                    fontWeight: FontWeight.bold,
                    height: 1.6,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizedText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: context.l10n.copyText,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: () {
                    final shareString =
                        '${wisdom.textAr}\n\n$localizedText\n— ${wisdom.reference}';
                    Clipboard.setData(ClipboardData(text: shareString));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.copiedToClipboard),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: context.l10n.shareWisdom,
                  icon: const Icon(Icons.share_rounded, size: 18),
                  onPressed: () {
                    final shareString =
                        '${wisdom.textAr}\n\n$localizedText\n— ${wisdom.reference}\n\nVia Prayer Assistant';
                    SharePlus.instance.share(ShareParams(text: shareString));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
