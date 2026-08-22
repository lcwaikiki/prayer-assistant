import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/l10n.dart';
import '../models/supplication_models.dart';

class DailyWisdomCard extends StatefulWidget {
  const DailyWisdomCard({
    super.key,
    required this.wisdom,
  });

  final DailyWisdom wisdom;

  @override
  State<DailyWisdomCard> createState() => _DailyWisdomCardState();
}

class _DailyWisdomCardState extends State<DailyWisdomCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final localizedText = widget.wisdom.localizedText(lang);
    final isAyah = widget.wisdom.type == 'ayah';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAyah
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAyah ? Icons.menu_book : Icons.auto_awesome,
                          size: 12,
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isAyah
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isExpanded) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.wisdom.reference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                  ],
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    tooltip: context.l10n.copyText,
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    onPressed: () {
                      final shareString =
                          '${widget.wisdom.textAr}\n\n$localizedText\n— ${widget.wisdom.reference}';
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
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    tooltip: context.l10n.shareWisdom,
                    icon: const Icon(Icons.share_rounded, size: 16),
                    onPressed: () {
                      final shareString =
                          '${widget.wisdom.textAr}\n\n$localizedText\n— ${widget.wisdom.reference}\n\nVia Prayer Assist';
                      SharePlus.instance.share(ShareParams(text: shareString));
                    },
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 2),
                Text(
                  widget.wisdom.reference,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 4),

              if (widget.wisdom.textAr.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      widget.wisdom.textAr,
                      textAlign: TextAlign.right,
                      maxLines: _isExpanded ? null : 1,
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
              ],
              if (_isExpanded && widget.wisdom.transliteration.isNotEmpty) ...[
                Text(
                  widget.wisdom.transliteration,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 3),
              ],

              Text(
                localizedText,
                maxLines: _isExpanded ? null : 2,
                overflow: _isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

