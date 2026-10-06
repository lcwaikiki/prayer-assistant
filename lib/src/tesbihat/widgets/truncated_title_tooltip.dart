import 'package:flutter/material.dart';

/// Renders a single-line title that truncates with ellipsis if it overflows,
/// and presents a floating tooltip balloon for ~2.5 seconds on tap only if
/// the title does not fit the available width.
class TruncatedTitleTooltip extends StatelessWidget {
  const TruncatedTitleTooltip({
    super.key,
    required this.title,
    this.style,
    this.maxLines = 1,
    this.badge,
    this.textKey,
  });

  final String title;
  final TextStyle? style;
  final int maxLines;
  final Widget? badge;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = style ?? theme.textTheme.titleMedium;

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: title, style: textStyle);
        final tp = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing =
            tp.didExceedMaxLines || tp.size.width > constraints.maxWidth;

        final textWidget = Text(
          title,
          key: textKey,
          style: textStyle,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        );

        if (!isOverflowing) {
          if (badge != null) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: textWidget),
                const SizedBox(width: 8),
                badge!,
              ],
            );
          }
          return textWidget;
        }

        final tooltipWidget = Tooltip(
          message: title,
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(milliseconds: 2500),
          waitDuration: Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: TextStyle(
            color: theme.colorScheme.onInverseSurface,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: textWidget,
        );

        if (badge != null) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: tooltipWidget),
              const SizedBox(width: 8),
              badge!,
            ],
          );
        }
        return tooltipWidget;
      },
    );
  }
}
