import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/prayer_app_controller.dart';
import '../kaza/screens/kaza_tracker_screen.dart';
import '../l10n/l10n.dart';
import '../models/prayer_models.dart';
import '../tesbihat/l10n/tesbihat_localizations.dart';
import '../tesbihat/screens/tesbih_home_screen.dart';
import '../tesbihat/state/groups_notifier.dart';
import '../tesbihat/state/items_notifier.dart';
import '../tesbihat/state/tesbih_selection.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'preferences_screen.dart';
import 'qibla_screen.dart';
import 'restore_options_dialog.dart';
import 'track_screen.dart';


const int _tesbihTabIndex = 4;

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.qiblaScreen});

  /// Injectable qibla tab content so tests can avoid the magnetometer and
  /// geolocator platform channels. Defaults to [QiblaScreen].
  final Widget? qiblaScreen;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  late final PrayerAppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<PrayerAppController>();
    _controller.addListener(_onTabChange);
    _updateOrientation(_controller.tabIndex);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.isInitializing) {
        _controller.addListener(_onInitializeDone);
      } else {
        _assessDriveRestore();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChange);
    _controller.removeListener(_onInitializeDone);
    _timer?.cancel();
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  void _onInitializeDone() {
    if (_controller.isInitializing) {
      return;
    }
    _controller.removeListener(_onInitializeDone);
    _assessDriveRestore();
  }

  void _onTabChange() {
    _updateOrientation(_controller.tabIndex);
  }

  void _updateOrientation(int tabIndex) {
    if (tabIndex == 4) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([]);
    }
  }

  static const _driveRestorePromptSeenKey = 'drive_restore_prompt_seen';

  /// Offers a Google Drive restore on a fresh install (no local data yet).
  /// Runs only after initialization completes so the data check is accurate.
  Future<void> _assessDriveRestore() async {
    final prefs = await SharedPreferences.getInstance();
    if (_controller.hasLocalData()) {
      await prefs.setBool(_driveRestorePromptSeenKey, true);
      return;
    }
    if (prefs.getBool(_driveRestorePromptSeenKey) ?? false) {
      return;
    }
    if (!mounted) {
      return;
    }
    _showDriveRestorePrompt();
  }

  void _showDriveRestorePrompt() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope<void>(
          canPop: false,
          child: AlertDialog(
            title: Text(context.l10n.googleDriveRestore),
            content: Text(context.l10n.driveRestorePromptBody),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _markDriveRestoreSeen();
                },
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _restoreFromFolder();
                },
                child: Text(context.l10n.offlineFolderRestore),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _restoreFromDrive();
                },
                child: Text(context.l10n.googleDriveRestore),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markDriveRestoreSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_driveRestorePromptSeenKey, true);
  }

  Future<void> _restoreFromDrive() async {
    await _markDriveRestoreSeen();
    try {
      final signedIn = await _controller.signInToGoogleDrive();
      if (!signedIn || !mounted) {
        return;
      }
      final backups = await _controller.listGoogleDriveBackups();
      if (!mounted) {
        return;
      }
      if (backups.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.googleDriveRestoreEmpty)),
        );
        return;
      }
      final selection = await showRestoreOptionsDialog(context);
      if (selection == null || !mounted) {
        return;
      }
      await _controller.restoreBackupFromGoogleDrive(
        backups.first.fileId,
        restoreData: selection.data,
        restorePreferences: selection.preferences,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.restoreSuccess)),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.restoreError}\n$e')),
      );
    }
  }

  /// Restores from the full backup file in the backup folder. Works fully
  /// offline; only asks for a folder when none is available (e.g. no
  /// Documents folder). The empty-data guard prevents clobbering it first.
  Future<void> _restoreFromFolder() async {
    await _markDriveRestoreSeen();
    try {
      if (!_controller.hasOfflineBackupFolder) {
        final chosen = await _controller.chooseOfflineBackupFolder();
        if (!chosen || !mounted) {
          return;
        }
      }
      final selection = await showRestoreOptionsDialog(context);
      if (selection == null || !mounted) {
        return;
      }
      await _controller.restoreFromOfflineFolder(
        restoreData: selection.data,
        restorePreferences: selection.preferences,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.restoreSuccess)),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.offlineFolderRestoreEmpty)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        if (controller.isInitializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final pages = <Widget>[
          widget.qiblaScreen ?? const QiblaScreen(embedded: true),
          const TrackScreen(),
          const HomeScreen(),
          const HistoryScreen(),
          const TesbihHomeScreen(),
        ];

        return riverpod.Consumer(
          builder: (context, ref, _) {
            final selection = ref.watch(tesbihSelectionProvider);
            return PopScope(
              canPop: !selection.active,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop && selection.active) {
                  ref.read(tesbihSelectionProvider.notifier).cancel();
                }
              },
              child: Scaffold(
              appBar: controller.tabIndex == _tesbihTabIndex && selection.active
                  ? _buildSelectionAppBar(context, ref)
                  : _buildAppBar(context, controller, _now, ref),
              body: SafeArea(
                child: _LazyIndexedStack(
                  index: controller.tabIndex,
                  children: pages,
                ),
              ),
              bottomNavigationBar: NavigationBar(
            selectedIndex: controller.tabIndex,
            onDestinationSelected: controller.setTab,
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore),
                label: context.l10n.qiblaTitle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.track_changes_outlined),
                selectedIcon: const Icon(Icons.track_changes),
                label: context.l10n.trackTabTitle,
              ),

              NavigationDestination(
                icon: const Icon(Icons.mosque_outlined),
                selectedIcon: const Icon(Icons.mosque),
                label: context.l10n.tabToday,
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                label: context.l10n.tabDates,
              ),
              NavigationDestination(
                icon: const Icon(Icons.circle_outlined),
                selectedIcon: const Icon(Icons.circle),
                label: context.l10n.tabTesbih,
              ),
            ],
          ),
        ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    PrayerAppController controller,
    DateTime now,
    riverpod.WidgetRef ref,
  ) {
    final tabTitle = switch (controller.tabIndex) {
      0 => context.l10n.qiblaTitle,
      1 => context.l10n.trackTabTitle,
      2 => context.l10n.tabToday,
      3 => context.l10n.tabDates,
      4 => context.l10n.tabTesbih,
      _ => context.l10n.appTitle,
    };


    final next = controller.nextPrayer(now);
    final minuteText = next == null
        ? context.l10n.remainingMinutesUnknown
        : context.l10n.remainingMinutesValue(
            next.remaining.inMinutes.clamp(0, 9999),
          );
    final isHomeTab = controller.tabIndex == 2;

    final placement = isHomeTab
        ? controller.appBarRemainingPlacement
        : AppBarRemainingPlacement.hidden;

    Widget titleWidget = Text(tabTitle);
    Widget? trailing;

    if (placement == AppBarRemainingPlacement.title) {
      titleWidget = Text('$tabTitle • $minuteText');
    } else if (placement == AppBarRemainingPlacement.subtitle) {
      titleWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(tabTitle),
          Text(minuteText, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
    } else if (placement == AppBarRemainingPlacement.trailing) {
      trailing = Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Chip(label: Text(minuteText)),
      );
    }

    return AppBar(
      title: titleWidget,
      actions: [
        if (trailing != null) trailing,
        if (controller.tabIndex == _tesbihTabIndex)
          IconButton(
            key: const Key('select_items_button'),
            tooltip: context.tesbihatL10n.select,
            icon: const Icon(Icons.checklist),
            onPressed: () =>
                ref.read(tesbihSelectionProvider.notifier).start(),
          ),
        IconButton(
          tooltip: controller.remindersSilenced
              ? context.l10n.tooltipRemindersOn
              : context.l10n.tooltipRemindersOff,
          icon: Icon(
            controller.remindersSilenced
                ? Icons.notifications_off_outlined
                : Icons.notifications_active_outlined,
          ),
          onPressed: controller.toggleReminders,
        ),
        IconButton(
          tooltip: context.l10n.tooltipToggleLightDark,
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
          onPressed: () => controller.toggleThemeQuick(
            isCurrentlyDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        IconButton(
          tooltip: context.l10n.tooltipPreferences,
          icon: const Icon(Icons.tune),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PreferencesScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(
    BuildContext context,
    riverpod.WidgetRef ref,
  ) {
    final l10n = context.tesbihatL10n;
    final selection = ref.watch(tesbihSelectionProvider);
    final notifier = ref.read(tesbihSelectionProvider.notifier);
    final allIds = <String>{
      ...ref.read(itemsNotifierProvider).map((item) => item.id),
      ...ref.read(groupsNotifierProvider).map((group) => group.id),
    };
    final allSelected =
        allIds.isNotEmpty && selection.count == allIds.length;
    return AppBar(
      leading: IconButton(
        key: const Key('cancel_selection_button'),
        tooltip: l10n.cancel,
        icon: const Icon(Icons.close),
        onPressed: notifier.cancel,
      ),
      title: Text(l10n.selectedCount(selection.count)),
      actions: [
        IconButton(
          key: const Key('select_all_items_button'),
          tooltip: l10n.selectAll,
          icon: Icon(allSelected ? Icons.deselect : Icons.select_all),
          onPressed: () {
            if (allSelected) {
              notifier.clearSelection();
            } else {
              notifier.setSelected(allIds);
            }
          },
        ),
        IconButton(
          key: const Key('bulk_delete_button'),
          tooltip: l10n.delete,
          icon: const Icon(Icons.delete_outline),
          onPressed: selection.count == 0
              ? null
              : () => _bulkDelete(context, ref),
        ),
      ],
    );
  }

  Future<void> _bulkDelete(
    BuildContext context,
    riverpod.WidgetRef ref,
  ) async {
    final l10n = context.tesbihatL10n;
    final selected = ref.read(tesbihSelectionProvider).selectedIds;
    if (selected.isEmpty) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteSelectedConfirm(selected.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final items = ref.read(itemsNotifierProvider);
    final groups = ref.read(groupsNotifierProvider);
    final itemIds = [
      for (final item in items)
        if (selected.contains(item.id)) item.id,
    ];
    final groupIds = [
      for (final group in groups)
        if (selected.contains(group.id)) group.id,
    ];
    ref.read(itemsNotifierProvider.notifier).deleteItems(itemIds);
    if (groupIds.isNotEmpty) {
      ref.read(itemsNotifierProvider.notifier).removeGroupsFromItems(groupIds);
      ref.read(groupsNotifierProvider.notifier).deleteGroups(groupIds);
    }
    ref.read(tesbihSelectionProvider.notifier).cancel();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.deletedSelected(selected.length))),
      );
  }
}

/// Renders one of [children] at [index], building each page lazily on its
/// first visit and keeping it mounted afterwards so its state (scroll
/// positions, tab selections, built table rows) survives tab switches.
class _LazyIndexedStack extends StatefulWidget {
  const _LazyIndexedStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late final List<bool> _visited = List<bool>.filled(
    widget.children.length,
    false,
  );

  @override
  Widget build(BuildContext context) {
    _visited[widget.index] = true;
    return IndexedStack(
      index: widget.index,
      sizing: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          if (_visited[i]) widget.children[i] else const SizedBox.shrink(),
      ],
    );
  }
}
