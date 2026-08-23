import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../calendar/hijri_utils.dart';
import '../calendar/screens/hijri_calendar_screen.dart';
import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../l10n/prayer_names.dart';
import '../models/prayer_models.dart';
import 'analytics_dashboard_screen.dart';


import '../utils/time_utils.dart';

const double _dateColWidth = 66;
const double _minTimeColWidth = 44;
const double _hijriColWidth = 108;

/// The time columns expand to fill a wide (tablet/landscape) screen while
/// staying at [densePhoneTableWidth] on narrow phones, so the table is
/// dense in portrait and uses the extra width in landscape.
const double densePhoneTableWidth =
    _dateColWidth + (_minTimeColWidth * 6) + _hijriColWidth;

double _timeColWidthFor(double available) {
  final perTime = (available - _dateColWidth - _hijriColWidth) / 6;
  return perTime < _minTimeColWidth ? _minTimeColWidth : perTime;
}

double _tableWidthFor(double available) =>
    _dateColWidth + _timeColWidthFor(available) * 6 + _hijriColWidth;

const double _monthHeaderHeight = 40;
const double _dayRowHeight = 38;
const double _monthCardBottomPadding = 8;
const double _monthSpacing = 12;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  final ScrollController _verticalController = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();
  final Map<String, ScrollController> _monthHorizontalControllers =
      <String, ScrollController>{};
  final Map<String, GlobalKey> _monthKeys = <String, GlobalKey>{};
  final Map<String, double> _monthTopOffsets = <String, double>{};
  final GlobalKey _todayRowKey = GlobalKey();
  bool _syncingHorizontal = false;
  int? _lastTabIndex;

  @override
  void dispose() {
    _tabController.dispose();
    _verticalController.dispose();
    _headerHorizontalController.dispose();
    for (final controller in _monthHorizontalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncHorizontalTo(double offset, {required String source}) {
    if (_syncingHorizontal) {
      return;
    }
    _syncingHorizontal = true;

    if (source != 'header' && _headerHorizontalController.hasClients) {
      final max = _headerHorizontalController.position.maxScrollExtent;
      _headerHorizontalController.jumpTo(offset.clamp(0.0, max));
    }

    for (final entry in _monthHorizontalControllers.entries) {
      if (source == entry.key || !entry.value.hasClients) {
        continue;
      }
      final max = entry.value.position.maxScrollExtent;
      entry.value.jumpTo(offset.clamp(0.0, max));
    }

    _syncingHorizontal = false;
  }

  void _scheduleScrollToToday(List<PrayerDay> days, {String? locale}) {
    if (days.isEmpty) {
      return;
    }
    final today = DateTime.now();
    final monthKey = DateFormat('MMMM yyyy', locale).format(today);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final estimatedTop = _monthTopOffsets[monthKey];
      if (estimatedTop != null && _verticalController.hasClients) {
        _verticalController.jumpTo(
          estimatedTop + (today.day - 1) * _dayRowHeight,
        );
      }
      _refineScrollToToday(monthKey, attempts: 12);
    });
  }

  void _refineScrollToToday(String monthKey, {required int attempts}) {
    if (attempts <= 0) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final targetContext = _todayRowKey.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          alignment: 0.18,
        );
        return;
      }
      final fallbackContext = _monthKeys[monthKey]?.currentContext;
      if (fallbackContext != null) {
        Scrollable.ensureVisible(
          fallbackContext,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          alignment: 0.08,
        );
        return;
      }
      if (_verticalController.hasClients) {
        final position = _verticalController.position;
        _verticalController.jumpTo(
          position.pixels + position.viewportDimension,
        );
      }
      _refineScrollToToday(monthKey, attempts: attempts - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        if (_lastTabIndex != controller.tabIndex) {
          _lastTabIndex = controller.tabIndex;
          if (controller.tabIndex == 2) {
            _scheduleScrollToToday(
              controller.yearRange,
              locale: Localizations.localeOf(context).toString(),
            );
          }
        }

        return Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: context.l10n.datesPrayerTimesTab,
                  icon: const Icon(Icons.schedule),
                ),
                Tab(
                  text: context.l10n.datesCalendarTab,
                  icon: const Icon(Icons.calendar_month),
                ),
                Tab(
                  text: context.l10n.analyticsTab,
                  icon: const Icon(Icons.bar_chart),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _KeepAlive(child: _buildPrayerTimesTab(context, controller)),
                  const _KeepAlive(child: HijriCalendarView()),
                  const _KeepAlive(child: AnalyticsDashboardScreen()),
                ],
              ),
            ),

          ],
        );
      },
    );
  }

  Widget _buildPrayerTimesTab(
    BuildContext context,
    PrayerAppController controller,
  ) {
    final selected = controller.selectedLocation;
    if (selected == null) {
      return Center(child: Text(context.l10n.historySelectLocationFirst));
    }

    final days = controller.yearRange;
    if (days.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final today = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final groupedByMonth = _groupByMonth(days, locale);
    _monthTopOffsets.clear();
    var cumulativeTop = 0.0;
    for (final entry in groupedByMonth.entries) {
      _monthKeys.putIfAbsent(entry.key, GlobalKey.new);
      _monthHorizontalControllers.putIfAbsent(entry.key, ScrollController.new);
      _monthTopOffsets[entry.key] = cumulativeTop + _monthHeaderHeight;
      cumulativeTop += _monthHeaderHeight +
          entry.value.length * _dayRowHeight +
          _monthCardBottomPadding +
          _monthSpacing;
    }
    final monthEntries = groupedByMonth.entries.toList(growable: false);

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.historyTableTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                clipBehavior: Clip.antiAlias,
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      _syncHorizontalTo(
                        notification.metrics.pixels,
                        source: 'header',
                      );
                      return false;
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // The header and the month tables derive their column
                        // widths from the same available width, so they stay
                        // aligned on every screen size: dense on phones,
                        // filling the width on tablets/landscape.
                        final timeColWidth =
                            _timeColWidthFor(constraints.maxWidth);
                        final tableWidth =
                            _tableWidthFor(constraints.maxWidth);
                        return SingleChildScrollView(
                          controller: _headerHorizontalController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
                            child: _StickyHeaderRow(
                              dateColWidth: _dateColWidth,
                              timeColWidth: timeColWidth,
                              hijriColWidth: _hijriColWidth,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: _verticalController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 84),
                itemCount: monthEntries.length,
                itemBuilder: (context, index) {
                  final entry = monthEntries[index];
                  return Padding(
                    key: _monthKeys[entry.key],
                    padding: const EdgeInsets.only(bottom: _monthSpacing),
                    child: _MonthTable(
                      month: entry.key,
                      days: entry.value,
                      today: today,
                      horizontalController:
                          _monthHorizontalControllers[entry.key]!,
                      onHorizontalScroll: (offset) => _syncHorizontalTo(
                        offset,
                        source: entry.key,
                      ),
                      todayRowKey: _todayRowKey,
                      isCompleted: controller.isPrayerCompleted,
                      onToggleCompleted: (prayer, date) =>
                          controller.togglePrayerCompletionForDate(
                            prayer,
                            date,
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            onPressed: () => _scheduleScrollToToday(
              days,
              locale: Localizations.localeOf(context).toString(),
            ),
            child: const Icon(Icons.today),
          ),
        ),
      ],
    );
  }
}

Map<String, List<PrayerDay>> _groupByMonth(List<PrayerDay> days, String locale) {
  final result = <String, List<PrayerDay>>{};
  for (final day in days) {
    final key = DateFormat('MMMM yyyy', locale).format(day.date);
    result.putIfAbsent(key, () => <PrayerDay>[]).add(day);
  }
  return result;
}

class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _MonthTable extends StatelessWidget {
  const _MonthTable({
    required this.month,
    required this.days,
    required this.today,
    required this.horizontalController,
    required this.onHorizontalScroll,
    required this.todayRowKey,
    required this.isCompleted,
    required this.onToggleCompleted,
  });

  final String month;
  final List<PrayerDay> days;
  final DateTime today;
  final ScrollController horizontalController;
  final ValueChanged<double> onHorizontalScroll;
  final GlobalKey todayRowKey;
  final bool Function(String prayerName, DateTime date) isCompleted;
  final void Function(String prayerName, DateTime date) onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.only(bottom: _monthCardBottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Text(
                month,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                onHorizontalScroll(notification.metrics.pixels);
                return false;
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Mirrors the sticky header's width derivation so the rows
                  // line up with it on every screen size: dense on phones,
                  // filling the width on tablets/landscape.
                  final timeColWidth = _timeColWidthFor(constraints.maxWidth);
                  final tableWidth = _tableWidthFor(constraints.maxWidth);
                  final double dateWidth = _dateColWidth;
                  final double timeWidth = timeColWidth;
                  final double hijriWidth = _hijriColWidth;
                  return SingleChildScrollView(
                    controller: horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: DataTableTheme(
                        data: DataTableThemeData(
                          headingTextStyle:
                              Theme.of(context).textTheme.labelLarge,
                          dataTextStyle:
                              Theme.of(context).textTheme.bodyMedium,
                        ),
                        child: DataTable(
                          horizontalMargin: 0,
                          columnSpacing: 0,
                          headingRowHeight: 0,
                          dataRowMinHeight: 38,
                          dataRowMaxHeight: 40,
                          columns: [
                            DataColumn(
                              label: SizedBox(width: dateWidth),
                              columnWidth: FixedColumnWidth(dateWidth),
                            ),
                            for (var i = 0; i < 6; i++)
                              DataColumn(
                                label: SizedBox(width: timeWidth),
                                columnWidth: FixedColumnWidth(timeWidth),
                              ),
                            DataColumn(
                              label: SizedBox(width: hijriWidth),
                              columnWidth: FixedColumnWidth(hijriWidth),
                            ),
                          ],
                          rows: List.generate(days.length, (index) {
                            final day = days[index];
                            final isToday =
                                day.date.year == today.year &&
                                day.date.month == today.month &&
                                day.date.day == today.day;
                            final baseColor = index.isEven
                                ? colors.surface
                                : colors.surfaceContainerLow;
                            final rowColor = isToday
                                ? colors.primaryContainer
                                : baseColor;

                            Text cellText(String value, {bool isDate = false}) {
                              return Text(
                                value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: isToday && isDate
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              );
                            }

                            return DataRow(
                              color: WidgetStatePropertyAll(rowColor),
                              cells: [
                                DataCell(
                                  SizedBox(
                                    key: isToday ? todayRowKey : null,
                                    width: dateWidth,
                                    child: cellText(
                                      isToday
                                          ? context.l10n.todayShort
                                          : DateFormat('dd/MM').format(
                                              day.date,
                                            ),
                                      isDate: true,
                                    ),
                                  ),
                                ),
                                for (final prayerName in prayerOrder)
                                  DataCell(
                                    GestureDetector(
                                      onTap: () => onToggleCompleted(
                                        prayerName,
                                        day.date,
                                      ),
                                      child: SizedBox(
                                        width: timeWidth,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              (() => switch (prayerName) {
                                                'Imsak' => day.imsak,
                                                'Gunes' => day.gunes,
                                                'Ogle' => day.ogle,
                                                'Ikindi' => day.ikindi,
                                                'Aksam' => day.aksam,
                                                'Yatsi' => day.yatsi,
                                                _ => '--:--',
                                              })(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: isCompleted(
                                                  prayerName,
                                                  day.date,
                                                )
                                                    ? FontWeight.w700
                                                    : FontWeight.w400,
                                                color: isCompleted(
                                                  prayerName,
                                                  day.date,
                                                )
                                                    ? Colors.green.shade700
                                                    : null,
                                              ),
                                            ),
                                            if (isCompleted(
                                              prayerName,
                                              day.date,
                                            ))
                                              Icon(
                                                Icons.check,
                                                size: 12,
                                                color: Colors.green.shade700,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                DataCell(
                                  SizedBox(
                                    width: hijriWidth,
                                    child: cellText(
                                      formatHijriDate(day.date,
                                          Localizations.localeOf(context)
                                              .languageCode),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderRow extends StatelessWidget {
  const _StickyHeaderRow({
    required this.dateColWidth,
    required this.timeColWidth,
    required this.hijriColWidth,
  });

  final double dateColWidth;
  final double timeColWidth;
  final double hijriColWidth;

  Widget _headerCell(String text, double width, TextStyle? style, {String? prayerKey}) {
    final color = style?.color;
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prayerKey != null) ...[
            Icon(
              iconForPrayer(prayerKey),
              size: 13,
              color: color,
            ),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              text,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    final l10n = context.l10n;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          _headerCell(l10n.dateHeader, dateColWidth, style),
          _headerCell(l10n.prayerNameLabel('Imsak'), timeColWidth, style, prayerKey: 'Imsak'),
          _headerCell(l10n.prayerNameLabel('Gunes'), timeColWidth, style, prayerKey: 'Gunes'),
          _headerCell(l10n.prayerNameLabel('Ogle'), timeColWidth, style, prayerKey: 'Ogle'),
          _headerCell(l10n.prayerNameLabel('Ikindi'), timeColWidth, style, prayerKey: 'Ikindi'),
          _headerCell(l10n.prayerNameLabel('Aksam'), timeColWidth, style, prayerKey: 'Aksam'),
          _headerCell(l10n.prayerNameLabel('Yatsi'), timeColWidth, style, prayerKey: 'Yatsi'),
          _headerCell(l10n.hijriHeader, hijriColWidth, style),
        ],
      ),
    );
  }

}
