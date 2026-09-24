import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Multi-select state for the Beads home screen's bulk-delete mode.
class TesbihSelection {
  const TesbihSelection({this.active = false, this.selectedIds = const {}});

  final bool active;
  final Set<String> selectedIds;

  int get count => selectedIds.length;

  bool contains(String id) => selectedIds.contains(id);

  TesbihSelection copyWith({bool? active, Set<String>? selectedIds}) {
    return TesbihSelection(
      active: active ?? this.active,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

final tesbihSelectionProvider =
    NotifierProvider<TesbihSelectionNotifier, TesbihSelection>(
      TesbihSelectionNotifier.new,
    );

class TesbihSelectionNotifier extends Notifier<TesbihSelection> {
  @override
  TesbihSelection build() => const TesbihSelection();

  void start() => state = const TesbihSelection(active: true);

  void cancel() => state = const TesbihSelection();

  void toggle(String id) {
    final next = {...state.selectedIds};
    if (!next.remove(id)) {
      next.add(id);
    }
    state = state.copyWith(selectedIds: next);
  }

  void setSelected(Set<String> ids) =>
      state = state.copyWith(selectedIds: ids);

  void clearSelection() => state = state.copyWith(selectedIds: const {});
}
