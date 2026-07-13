import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../models/prayer_models.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  LocationNode? _country;
  LocationNode? _state;
  LocationNode? _district;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<PrayerAppController>();
    final selected = controller.selectedLocation;
    if (selected != null &&
        controller.countries.isNotEmpty &&
        _country == null) {
      _country = controller.countries.firstWhere(
        (item) => item.id == selected.countryId,
        orElse: () => controller.countries.first,
      );
      if (controller.states.isNotEmpty) {
        _state = controller.states.firstWhere(
          (item) => item.id == selected.stateId,
          orElse: () => controller.states.first,
        );
      }
      if (controller.districts.isNotEmpty) {
        _district = controller.districts.firstWhere(
          (item) => item.id == selected.districtId,
          orElse: () => controller.districts.first,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final error = controller.error;
        if (error != null && error.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          });
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              context.l10n.selectYourLocation,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.locationHelp,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: controller.isBusy ? null : controller.autoPickFromGps,
              icon: const Icon(Icons.my_location),
              label: Text(context.l10n.useCurrentLocation),
            ),
            const SizedBox(height: 24),
            _LocationDropdown(
              title: context.l10n.country,
              value: _country,
              items: controller.countries,
              onChanged: controller.isBusy
                  ? null
                  : (value) async {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _country = value;
                        _state = null;
                        _district = null;
                      });
                      await controller.chooseCountry(value);
                    },
            ),
            const SizedBox(height: 16),
            _LocationDropdown(
              title: context.l10n.stateCity,
              value: _state,
              items: controller.states,
              onChanged: controller.isBusy
                  ? null
                  : (value) async {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _state = value;
                        _district = null;
                      });
                      await controller.chooseState(value);
                    },
            ),
            const SizedBox(height: 16),
            _LocationDropdown(
              title: context.l10n.district,
              value: _district,
              items: controller.districts,
              onChanged: controller.isBusy
                  ? null
                  : (value) {
                      setState(() => _district = value);
                    },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed:
                  controller.isBusy ||
                      _country == null ||
                      _state == null ||
                      _district == null
                  ? null
                  : () async {
                      await controller.saveSelectedLocation(
                        country: _country!,
                        state: _state!,
                        district: _district!,
                      );
                    },
              child: Text(context.l10n.saveLocation),
            ),
            const SizedBox(height: 16),
            if (controller.selectedLocation != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    context.l10n.selectedLocation(
                      controller.selectedLocation!.fullName,
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            if (controller.isBusy)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}

class _LocationDropdown extends StatelessWidget {
  const _LocationDropdown({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String title;
  final LocationNode? value;
  final List<LocationNode> items;
  final ValueChanged<LocationNode?>? onChanged;

  @override
  Widget build(BuildContext context) {
    LocationNode? resolvedValue;
    if (value != null) {
      final index = items.indexWhere((item) => item.id == value!.id);
      if (index >= 0) {
        resolvedValue = items[index];
      }
    }

    return DropdownButtonFormField<LocationNode>(
      key: ValueKey('${title}_${resolvedValue?.id ?? 'none'}_${items.length}'),
      initialValue: resolvedValue,
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<LocationNode>(
              value: item,
              child: Text(item.name),
            ),
          )
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }
}
