import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import '../hijri_utils.dart';

class _HijriPickerStrings {
  const _HijriPickerStrings({
    required this.title,
    required this.yearLabel,
    required this.monthLabel,
    required this.dayLabel,
    required this.cancel,
    required this.go,
  });

  final String title;
  final String yearLabel;
  final String monthLabel;
  final String dayLabel;
  final String cancel;
  final String go;

  static const Map<String, _HijriPickerStrings> _byLang = {
    'tr': _HijriPickerStrings(
      title: 'Hicri Tarihe Git',
      yearLabel: 'Yıl',
      monthLabel: 'Ay',
      dayLabel: 'Gün',
      cancel: 'İptal',
      go: 'Git',
    ),
    'en': _HijriPickerStrings(
      title: 'Go to Hijri Date',
      yearLabel: 'Year',
      monthLabel: 'Month',
      dayLabel: 'Day',
      cancel: 'Cancel',
      go: 'Go',
    ),
    'ar': _HijriPickerStrings(
      title: 'الانتقال إلى تاريخ هجري',
      yearLabel: 'السنة',
      monthLabel: 'الشهر',
      dayLabel: 'اليوم',
      cancel: 'إلغاء',
      go: 'انتقال',
    ),
    'de': _HijriPickerStrings(
      title: 'Zu Hidschri-Datum springen',
      yearLabel: 'Jahr',
      monthLabel: 'Monat',
      dayLabel: 'Tag',
      cancel: 'Abbrechen',
      go: 'Los',
    ),
    'es': _HijriPickerStrings(
      title: 'Ir a fecha islámica',
      yearLabel: 'Año',
      monthLabel: 'Mes',
      dayLabel: 'Día',
      cancel: 'Cancelar',
      go: 'Ir',
    ),
    'fa': _HijriPickerStrings(
      title: 'رفتن به تاریخ هجری',
      yearLabel: 'سال',
      monthLabel: 'ماه',
      dayLabel: 'روز',
      cancel: 'لغو',
      go: 'برو',
    ),
    'fr': _HijriPickerStrings(
      title: 'Aller à la date hégirienne',
      yearLabel: 'Année',
      monthLabel: 'Mois',
      dayLabel: 'Jour',
      cancel: 'Annuler',
      go: 'Aller',
    ),
    'id': _HijriPickerStrings(
      title: 'Buka Tanggal Hijriah',
      yearLabel: 'Tahun',
      monthLabel: 'Bulan',
      dayLabel: 'Hari',
      cancel: 'Batal',
      go: 'Buka',
    ),
    'ja': _HijriPickerStrings(
      title: 'ヒジュラ歴の日付へ移動',
      yearLabel: '年',
      monthLabel: '月',
      dayLabel: '日',
      cancel: 'キャンセル',
      go: '移動',
    ),
    'ru': _HijriPickerStrings(
      title: 'Перейти к дате Хиджры',
      yearLabel: 'Год',
      monthLabel: 'Месяц',
      dayLabel: 'День',
      cancel: 'Отмена',
      go: 'Перейти',
    ),
    'ur': _HijriPickerStrings(
      title: 'ہجری تاریخ پر جائیں',
      yearLabel: 'سال',
      monthLabel: 'مہینہ',
      dayLabel: 'دن',
      cancel: 'منسوخ',
      go: 'جائیں',
    ),
    'zh': _HijriPickerStrings(
      title: '前往伊斯兰历日期',
      yearLabel: '年',
      monthLabel: '月',
      dayLabel: '日',
      cancel: '取消',
      go: '前往',
    ),
  };

  static _HijriPickerStrings of(String languageCode) {
    return _byLang[languageCode.toLowerCase()] ?? _byLang['en']!;
  }
}

/// Displays a dialog allowing the user to select a Hijri date (year, month, day)
/// and converts it to a Gregorian [DateTime].
Future<DateTime?> showHijriDatePickerDialog(
  BuildContext context, {
  required DateTime initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) => _HijriDatePickerDialog(initialDate: initialDate),
  );
}

class _HijriDatePickerDialog extends StatefulWidget {
  const _HijriDatePickerDialog({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_HijriDatePickerDialog> createState() => _HijriDatePickerDialogState();
}

class _HijriDatePickerDialogState extends State<_HijriDatePickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  static const int minYear = 1356;
  static const int maxYear = 1500;

  @override
  void initState() {
    super.initState();
    final hijri = HijriCalendar.fromDate(widget.initialDate);
    _selectedYear = hijri.hYear.clamp(minYear, maxYear);
    _selectedMonth = hijri.hMonth.clamp(1, 12);
    final maxDays = HijriCalendar().getDaysInMonth(_selectedYear, _selectedMonth);
    _selectedDay = hijri.hDay.clamp(1, maxDays);
  }

  int get _maxDaysInCurrentMonth =>
      HijriCalendar().getDaysInMonth(_selectedYear, _selectedMonth);

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final strings = _HijriPickerStrings.of(languageCode);
    final maxDays = _maxDaysInCurrentMonth;
    if (_selectedDay > maxDays) {
      _selectedDay = maxDays;
    }

    return AlertDialog(
      title: Text(strings.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Year Selector
            Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    strings.yearLabel,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: const Key('hijri_year_dropdown'),
                    value: _selectedYear,
                    isDense: true,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var y = minYear; y <= maxYear; y++)
                        DropdownMenuItem<int>(
                          value: y,
                          child: Text('$y AH'),
                        ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedYear = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Month Selector
            Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    strings.monthLabel,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: const Key('hijri_month_dropdown'),
                    value: _selectedMonth,
                    isDense: true,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var m = 1; m <= 12; m++)
                        DropdownMenuItem<int>(
                          value: m,
                          child: Text(
                            '$m - ${HijriMonth(_selectedYear, m).longMonthName(languageCode)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMonth = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Day Selector
            Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    strings.dayLabel,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: const Key('hijri_day_dropdown'),
                    value: _selectedDay,
                    isDense: true,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var d = 1; d <= maxDays; d++)
                        DropdownMenuItem<int>(
                          value: d,
                          child: Text(d.toString()),
                        ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDay = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('hijri_picker_cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
        FilledButton(
          key: const Key('hijri_picker_confirm'),
          onPressed: () {
            final gregorian = HijriCalendar().hijriToGregorian(
              _selectedYear,
              _selectedMonth,
              _selectedDay,
            );
            Navigator.of(context).pop(gregorian);
          },
          child: Text(strings.go),
        ),
      ],
    );
  }
}
