import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import '../l10n/country_names.dart';
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

        final languageCode = Localizations.localeOf(context).languageCode;
        String countryLabel(LocationNode node) =>
            localizedCountryName(node.name, languageCode);

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
            _SearchableLocationField(
              title: context.l10n.country,
              value: country,
              items: controller.countries,
              labelBuilder: countryLabel,
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
            _SearchableLocationField(
              title: context.l10n.stateCity,
              value: state,
              items: controller.states,
              labelBuilder: (node) => node.name,
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
            _SearchableLocationField(
              title: context.l10n.district,
              value: district,
              items: controller.districts,
              labelBuilder: (node) => node.name,
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

/// A tappable field that opens a searchable bottom sheet for picking a
/// [LocationNode]. Items are shown in ascending order by their display name.
class _SearchableLocationField extends StatelessWidget {
  const _SearchableLocationField({
    required this.title,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String title;
  final LocationNode? value;
  final List<LocationNode> items;
  final String Function(LocationNode) labelBuilder;
  final ValueChanged<LocationNode?>? onChanged;

  Future<void> _open(BuildContext context) async {
    if (onChanged == null || items.isEmpty) {
      return;
    }
    final selected = await showModalBottomSheet<LocationNode>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => _LocationPickerSheet(
        title: title,
        items: items,
        labelBuilder: labelBuilder,
        selectedId: value?.id,
      ),
    );
    if (selected != null) {
      onChanged!(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null && items.isNotEmpty;
    return InkWell(
      onTap: enabled ? () => _open(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.search),
          enabled: enabled,
        ),
        child: Text(
          value == null ? '' : labelBuilder(value!),
          style: Theme.of(context).textTheme.bodyLarge,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet({
    required this.title,
    required this.items,
    required this.labelBuilder,
    required this.selectedId,
  });

  final String title;
  final List<LocationNode> items;
  final String Function(LocationNode) labelBuilder;
  final String? selectedId;

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<LocationNode> _sorted;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _sorted = [...widget.items]
      ..sort(
        (a, b) => widget
            .labelBuilder(a)
            .toLowerCase()
            .compareTo(widget.labelBuilder(b).toLowerCase()),
      );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LocationNode> get _filtered {
    if (_query.trim().isEmpty) {
      return _sorted;
    }
    final q = _query.trim().toLowerCase();
    return _sorted
        .where((node) => widget.labelBuilder(node).toLowerCase().contains(q))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              key: const Key('location_search_field'),
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: context.l10n.search,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(context.l10n.noResults))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final node = filtered[index];
                      final isSelected = node.id == widget.selectedId;
                      return ListTile(
                        title: Text(widget.labelBuilder(node)),
                        trailing: isSelected
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => Navigator.of(context).pop(node),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
