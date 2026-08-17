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
  String? _lastShownError;

  static LocationNode? _findById(List<LocationNode> items, String id) {
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  /// The shell already switched to the Home tab on a successful save; close
  /// the pushed location (and preferences) routes so the user lands there.
  void _closeAfterSave(PrayerAppController controller) {
    if (context.mounted && controller.error == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void initState() {
    super.initState();
    // Retry the startup option fetch when it failed (empty country list).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PrayerAppController>().reloadLocationOptions();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<PrayerAppController>();
    final selected = controller.selectedLocation;
    // Only auto-select when the saved ids still exist in the loaded lists;
    // a stale/foreign id must not silently fall back to another entry.
    if (selected != null &&
        controller.countries.isNotEmpty &&
        _country == null) {
      final country = _findById(controller.countries, selected.countryId);
      if (country != null) {
        _country = country;
        _state = _findById(controller.states, selected.stateId);
        _district = _findById(controller.districts, selected.districtId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final error = controller.error;
        // Show each distinct error once; a stale error must not re-pop
        // on every rebuild (e.g. tapping the GPS button would otherwise
        // surface an old startup failure).
        if (error != null && error.isNotEmpty && error != _lastShownError) {
          _lastShownError = error;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          });
        }

        // A GPS pick (or a save elsewhere) sets the controller's location
        // without touching this screen's local state; resolve the dropdowns
        // from the saved location while the user hasn't started a manual
        // pick, so the found location is reflected immediately.
        final saved = controller.selectedLocation;
        final country =
            _country ??
            (saved != null
                ? _findById(controller.countries, saved.countryId)
                : null);
        final state =
            _country == null
                ? _state ??
                      (saved != null
                          ? _findById(controller.states, saved.stateId)
                          : null)
                : _state;
        final district =
            _country == null
                ? _district ??
                      (saved != null
                          ? _findById(controller.districts, saved.districtId)
                          : null)
                : _district;

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
              onPressed: controller.isBusy
                  ? null
                  : () async {
                      final picked = await controller.autoPickFromGps();
                      if (mounted && picked != null) {
                        setState(() {
                          _country = picked.country;
                          _state = picked.state;
                          _district = picked.district;
                        });
                      }
                    },
              icon: const Icon(Icons.my_location),
              label: Text(context.l10n.useCurrentLocation),
            ),
            const SizedBox(height: 24),
            _LocationDropdown(
              title: context.l10n.country,
              value: country,
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
              value: state,
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
              value: district,
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
                  controller.isBusy || country == null || state == null ||
                      district == null
                  ? null
                  : () async {
                      await controller.saveSelectedLocation(
                        country: country,
                        state: state,
                        district: district,
                      );
                      _closeAfterSave(controller);
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

