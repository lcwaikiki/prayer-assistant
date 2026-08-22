import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../l10n/prayer_names.dart';
import '../models/kaza_tracker.dart';


class KazaCalculatorDialog extends StatefulWidget {
  const KazaCalculatorDialog({
    super.key,
    required this.initialTracker,
    required this.onSave,
  });

  final KazaTracker initialTracker;
  final ValueChanged<KazaTracker> onSave;

  @override
  State<KazaCalculatorDialog> createState() => _KazaCalculatorDialogState();
}

class _KazaCalculatorDialogState extends State<KazaCalculatorDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _yearsController = TextEditingController(text: '0');
  final _monthsController = TextEditingController(text: '0');

  late final TextEditingController _fajrController;
  late final TextEditingController _dhuhrController;
  late final TextEditingController _asrController;
  late final TextEditingController _maghribController;
  late final TextEditingController _ishaController;
  late final TextEditingController _witrController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fajrController = TextEditingController(
      text: widget.initialTracker.fajrTarget.toString(),
    );
    _dhuhrController = TextEditingController(
      text: widget.initialTracker.dhuhrTarget.toString(),
    );
    _asrController = TextEditingController(
      text: widget.initialTracker.asrTarget.toString(),
    );
    _maghribController = TextEditingController(
      text: widget.initialTracker.maghribTarget.toString(),
    );
    _ishaController = TextEditingController(
      text: widget.initialTracker.ishaTarget.toString(),
    );
    _witrController = TextEditingController(
      text: widget.initialTracker.witrTarget.toString(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _yearsController.dispose();
    _monthsController.dispose();
    _fajrController.dispose();
    _dhuhrController.dispose();
    _asrController.dispose();
    _maghribController.dispose();
    _ishaController.dispose();
    _witrController.dispose();
    super.dispose();
  }

  void _submitCalculated() {
    if (_tabController.index == 0) {
      final years = int.tryParse(_yearsController.text.trim()) ?? 0;
      final months = int.tryParse(_monthsController.text.trim()) ?? 0;
      final totalDays = (years * 365) + (months * 30);

      final updated = widget.initialTracker.copyWith(
        fajrTarget: totalDays,
        dhuhrTarget: totalDays,
        asrTarget: totalDays,
        maghribTarget: totalDays,
        ishaTarget: totalDays,
        witrTarget: totalDays,
      );
      widget.onSave(updated);
    } else {
      final updated = widget.initialTracker.copyWith(
        fajrTarget: int.tryParse(_fajrController.text.trim()) ?? 0,
        dhuhrTarget: int.tryParse(_dhuhrController.text.trim()) ?? 0,
        asrTarget: int.tryParse(_asrController.text.trim()) ?? 0,
        maghribTarget: int.tryParse(_maghribController.text.trim()) ?? 0,
        ishaTarget: int.tryParse(_ishaController.text.trim()) ?? 0,
        witrTarget: int.tryParse(_witrController.text.trim()) ?? 0,
      );
      widget.onSave(updated);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.kazaCalculatorTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: context.l10n.kazaCalculateByYears),
                  Tab(text: context.l10n.kazaCalculateManual),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 195,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Years/Months Calculator
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          TextField(
                            controller: _yearsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: context.l10n.kazaYearsMissed,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _monthsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: context.l10n.kazaMonthsMissed,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ValueListenableBuilder(
                            valueListenable: _yearsController,
                            builder: (context, _, __) {
                              final years =
                                  int.tryParse(_yearsController.text.trim()) ??
                                  0;
                              final months =
                                  int.tryParse(_monthsController.text.trim()) ??
                                  0;
                              final days = (years * 365) + (months * 30);
                              return Text(
                                context.l10n.kazaCalculatedDaysPerPrayer(
                                  days,
                                  days * 6,
                                ),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Tab 2: Manual Entry for all 6 prayers
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            children: [

                              Expanded(
                                child: _buildPrayerTargetInput(
                                  context,
                                  context.l10n.prayerNameLabel('Imsak'),
                                  _fajrController,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildPrayerTargetInput(
                                  context,
                                  context.l10n.prayerNameLabel('Ogle'),
                                  _dhuhrController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPrayerTargetInput(
                                  context,
                                  context.l10n.prayerNameLabel('Ikindi'),
                                  _asrController,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildPrayerTargetInput(
                                  context,
                                  context.l10n.prayerNameLabel('Aksam'),
                                  _maghribController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPrayerTargetInput(
                                  context,
                                  context.l10n.prayerNameLabel('Yatsi'),
                                  _ishaController,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildPrayerTargetInput(
                                  context,
                                  context.l10n.kazaWitrLabel,
                                  _witrController,
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 4),
              OverflowBar(

                alignment: MainAxisAlignment.end,
                spacing: 8,
                overflowSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: _submitCalculated,
                    child: Text(
                      context.l10n.kazaCalculateButton,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTargetInput(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}
