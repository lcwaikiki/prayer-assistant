import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../calendar/screens/hijri_calendar_screen.dart';
import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../models/prayer_models.dart';

const double _dateColWidth = 66;
const double _timeColWidth = 44;
const double _hijriColWidth = 108;
const double _tableWidth = _dateColWidth + (_timeColWidth * 6) + _hijriColWidth;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  final ScrollController _verticalController = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();
  final Map<String, ScrollController> _monthHorizontalControllers =
      <String, ScrollController>{};
  final Map<String, GlobalKey> _monthKeys = <String, GlobalKey>{};
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
      final monthKey =
          DateFormat('MMMM yyyy', locale).format(DateTime.now());
      final fallbackContext = _monthKeys[monthKey]?.currentContext;
      if (fallbackContext != null) {
        Scrollable.ensureVisible(
          fallbackContext,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          alignment: 0.08,
        );
      }
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
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPrayerTimesTab(context, controller),
                  const HijriCalendarView(),
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
    for (final month in groupedByMonth.keys) {
      _monthKeys.putIfAbsent(month, GlobalKey.new);
      _monthHorizontalControllers.putIfAbsent(month, ScrollController.new);
    }

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
                  child: SingleChildScrollView(
                    controller: _headerHorizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: _tableWidth,
                      child: const _StickyHeaderRow(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                controller: _verticalController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 84),
                  child: Column(
                    children: groupedByMonth.entries
                        .map(
                          (entry) => Padding(
                            key: _monthKeys[entry.key],
                            padding: const EdgeInsets.only(bottom: 12),
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
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
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

class _MonthTable extends StatelessWidget {
  const _MonthTable({
    required this.month,
    required this.days,
    required this.today,
    required this.horizontalController,
    required this.onHorizontalScroll,
    required this.todayRowKey,
  });

  final String month;
  final List<PrayerDay> days;
  final DateTime today;
  final ScrollController horizontalController;
  final ValueChanged<double> onHorizontalScroll;
  final GlobalKey todayRowKey;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
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
              child: SingleChildScrollView(
                controller: horizontalController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _tableWidth,
                  child: DataTableTheme(
                    data: DataTableThemeData(
                      headingTextStyle: Theme.of(context).textTheme.labelLarge,
                      dataTextStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    child: DataTable(
                      horizontalMargin: 0,
                      columnSpacing: 0,
                      headingRowHeight: 0,
                      dataRowMinHeight: 38,
                      dataRowMaxHeight: 40,
                      columns: const [
                        DataColumn(label: SizedBox(width: _dateColWidth)),
                        DataColumn(label: SizedBox(width: _timeColWidth)),
                        DataColumn(label: SizedBox(width: _timeColWidth)),
                        DataColumn(label: SizedBox(width: _timeColWidth)),
                        DataColumn(label: SizedBox(width: _timeColWidth)),
                        DataColumn(label: SizedBox(width: _timeColWidth)),
                        DataColumn(label: SizedBox(width: _timeColWidth)),
                        DataColumn(label: SizedBox(width: _hijriColWidth)),
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
                                width: _dateColWidth,
                                child: cellText(
                                  isToday
                                      ? context.l10n.todayShort
                                      : DateFormat('dd/MM').format(day.date),
                                  isDate: true,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: _timeColWidth,
                                child: cellText(day.imsak),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: _timeColWidth,
                                child: cellText(day.gunes),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: _timeColWidth,
                                child: cellText(day.ogle),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: _timeColWidth,
                                child: cellText(day.ikindi),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: _timeColWidth,
                                child: cellText(day.aksam),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: _timeColWidth,
                                child: cellText(day.yatsi),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: _hijriColWidth,
                                child: cellText(
                                  day.hijriDate.isEmpty ? '-' : day.hijriDate,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
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

class _StickyHeaderRow extends StatelessWidget {
  const _StickyHeaderRow();

  Widget _headerCell(String text, double width, TextStyle? style) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
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
          _headerCell(l10n.dateHeader, _dateColWidth, style),
          _headerCell(l10n.prayerNameLabel('Imsak'), _timeColWidth, style),
          _headerCell(l10n.prayerNameLabel('Gunes'), _timeColWidth, style),
          _headerCell(l10n.prayerNameLabel('Ogle'), _timeColWidth, style),
          _headerCell(l10n.prayerNameLabel('Ikindi'), _timeColWidth, style),
          _headerCell(l10n.prayerNameLabel('Aksam'), _timeColWidth, style),
          _headerCell(l10n.prayerNameLabel('Yatsi'), _timeColWidth, style),
          _headerCell(l10n.hijriHeader, _hijriColWidth, style),
        ],
      ),
    );
  }
}
