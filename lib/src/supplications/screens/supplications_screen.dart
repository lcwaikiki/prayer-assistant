import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';

import '../../l10n/l10n.dart';
import '../models/supplication_models.dart';
import '../services/wisdom_service.dart';

class SupplicationsScreen extends StatefulWidget {
  const SupplicationsScreen({super.key});

  @override
  State<SupplicationsScreen> createState() => _SupplicationsScreenState();
}

class _SupplicationsScreenState extends State<SupplicationsScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getCategoryLabel(BuildContext context, String cat) {
    switch (cat) {
      case 'morning':
        return context.l10n.morningAdhkar;
      case 'evening':
        return context.l10n.eveningAdhkar;
      case 'after_prayer':
        return context.l10n.afterPrayerAdhkar;
      case 'sleeping':
        return context.l10n.sleepingAdhkar;
      case 'daily_life':
        return context.l10n.dailyLifeDuas;
      default:
        return context.l10n.tabAll;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final items = _searchQuery.isNotEmpty
        ? WisdomService.instance.searchSupplications(_searchQuery, lang)
        : WisdomService.instance.getSupplicationsByCategory(_selectedCategory);

    final categories = [
      'all',
      'morning',
      'evening',
      'after_prayer',
      'sleeping',
      'daily_life',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.hisnAlMuslimTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l10n.searchSupplicationsHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
          ),
          if (_searchQuery.isEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  for (final cat in categories) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: _selectedCategory == cat,
                        label: Text(_getCategoryLabel(context, cat)),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined,
                            size: 48, color: theme.colorScheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.noSupplicationsFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _SupplicationCard(
                        item: item,
                        onTap: () => _openCounterModal(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openCounterModal(BuildContext context, SupplicationItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(child: _CounterModal(item: item)),
    );

  }
}

class _SupplicationCard extends StatelessWidget {
  const _SupplicationCard({
    required this.item,
    required this.onTap,
  });

  final SupplicationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final localizedText = item.localizedText(lang);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.targetCount}x',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.reference,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.touch_app_outlined,
                      size: 18, color: theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    item.textAr,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizedText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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

class _CounterModal extends StatefulWidget {
  const _CounterModal({required this.item});

  final SupplicationItem item;

  @override
  State<_CounterModal> createState() => _CounterModalState();
}

class _CounterModalState extends State<_CounterModal> {
  int _count = 0;

  void _increment() async {
    if (_count < widget.item.targetCount) {
      setState(() => _count++);
      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 40);
        }

      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final localizedText = widget.item.localizedText(lang);
    final target = widget.item.targetCount;
    final isDone = _count >= target;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.item.reference,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20),
                onPressed: () {
                  final text =
                      '${widget.item.textAr}\n\n$localizedText\n— ${widget.item.reference}';
                  SharePlus.instance.share(ShareParams(text: text));
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              widget.item.textAr,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            localizedText,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _increment,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? Colors.green.shade600
                    : theme.colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: isDone
                        ? Colors.green.withValues(alpha: 0.3)
                        : theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isDone) ...[
                      const Icon(Icons.check, size: 36, color: Colors.white),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.completed,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '$_count / $target',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        context.l10n.tapToCount,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
