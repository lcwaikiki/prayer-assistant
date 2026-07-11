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

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: days.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _HistoryCard(day: days[index]),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.day});

  final PrayerDay day;

  @override
  Widget build(BuildContext context) {
    final values = <String, String>{
      'Imsak': day.imsak,
      'Gunes': day.gunes,
      'Ogle': day.ogle,
      'Ikindi': day.ikindi,
      'Aksam': day.aksam,
      'Yatsi': day.yatsi,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEE, dd MMM yyyy').format(day.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: values.entries
                  .map(
                    (entry) =>
                        Chip(label: Text('${entry.key}: ${entry.value}')),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}
