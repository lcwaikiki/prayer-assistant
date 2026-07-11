import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import '../models/prayer_models.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final selected = controller.selectedLocation;
        if (selected == null) {
          return const Center(
            child: Text('Select a location first to view 1-year prayer list.'),
          );
        }

        final days = controller.yearRange;
        if (days.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Prayer Times Table (1 Year)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 540,
                  child: DataTableTheme(
                    data: DataTableThemeData(
                      headingTextStyle: Theme.of(context).textTheme.labelLarge,
                      dataTextStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    child: PaginatedDataTable(
                      header: const Text('Dates'),
                      rowsPerPage: 20,
                      showFirstLastButtons: true,
                      horizontalMargin: 0,
                      columnSpacing: 0,
                      headingRowHeight: 40,
                      dataRowMinHeight: 38,
                      dataRowMaxHeight: 40,
                      columns: const [
                        DataColumn(
                          label: SizedBox(width: 66, child: Text('Date')),
                        ),
                        DataColumn(
                          label: SizedBox(width: 44, child: Text('Imsak')),
                        ),
                        DataColumn(
                          label: SizedBox(width: 44, child: Text('Gunes')),
                        ),
                        DataColumn(
                          label: SizedBox(width: 44, child: Text('Ogle')),
                        ),
                        DataColumn(
                          label: SizedBox(width: 44, child: Text('Ikindi')),
                        ),
                        DataColumn(
                          label: SizedBox(width: 44, child: Text('Aksam')),
                        ),
                        DataColumn(
                          label: SizedBox(width: 44, child: Text('Yatsi')),
                        ),
                        DataColumn(
                          label: SizedBox(width: 108, child: Text('Hijri')),
                        ),
                      ],
                      source: _PrayerTableSource(
                        days,
                        oddRowColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        evenRowColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PrayerTableSource extends DataTableSource {
  _PrayerTableSource(
    this.days, {
    required this.oddRowColor,
    required this.evenRowColor,
  });

  final List<PrayerDay> days;
  final Color oddRowColor;
  final Color evenRowColor;

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= days.length) {
      return null;
    }
    final day = days[index];
    return DataRow.byIndex(
      index: index,
      color: WidgetStatePropertyAll(index.isEven ? evenRowColor : oddRowColor),
      cells: [
        DataCell(
          SizedBox(
            width: 66,
            child: Text(DateFormat('dd/MM').format(day.date)),
          ),
        ),
        DataCell(SizedBox(width: 44, child: Text(day.imsak))),
        DataCell(SizedBox(width: 44, child: Text(day.gunes))),
        DataCell(SizedBox(width: 44, child: Text(day.ogle))),
        DataCell(SizedBox(width: 44, child: Text(day.ikindi))),
        DataCell(SizedBox(width: 44, child: Text(day.aksam))),
        DataCell(SizedBox(width: 44, child: Text(day.yatsi))),
        DataCell(
          SizedBox(
            width: 108,
            child: Text(day.hijriDate.isEmpty ? '-' : day.hijriDate),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => days.length;

  @override
  int get selectedRowCount => 0;
}
