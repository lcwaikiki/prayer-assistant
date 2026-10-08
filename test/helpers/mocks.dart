import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/services/google_drive_backup_service.dart';
import 'package:prayer_assistant/src/services/offline_folder_backup_service.dart';
import 'package:prayer_assistant/src/calendar/services/calendar_reminder_service.dart';
import 'package:prayer_assistant/src/services/imsakiyem_api.dart';
import 'package:prayer_assistant/src/services/local_database.dart';
import 'package:prayer_assistant/src/services/location_resolver.dart';
import 'package:prayer_assistant/src/services/notification_service.dart';
import 'package:prayer_assistant/src/services/widget_bridge_service.dart';
import 'package:prayer_assistant/src/tesbihat/services/audio_player_service.dart';
import 'package:prayer_assistant/src/tesbihat/services/haptic_service.dart';
import 'package:prayer_assistant/src/tesbihat/services/item_reminder_service.dart';

class MockImsakiyemApi extends Mock implements ImsakiyemApi {}

class MockLocalDatabase extends Mock implements LocalDatabase {}

class MockLocationResolver extends Mock implements LocationResolver {}

class MockNotificationService extends Mock implements NotificationService {}

class MockWidgetBridgeService extends Mock implements WidgetBridgeService {}

class MockCalendarReminderService extends Mock
    implements CalendarReminderService {}

class MockItemReminderService extends Mock implements ItemReminderService {}

class MockHapticService extends Mock implements HapticService {}

class MockGoogleDriveBackupService extends Mock
    implements GoogleDriveBackupService {}

class MockOfflineFolderBackupService extends Mock
    implements OfflineFolderBackupService {}

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

class FakeAudioPlayerService implements AudioPlayerService {
  final _completeController = StreamController<void>.broadcast(sync: true);
  final _stateController = StreamController<PlayerState>.broadcast(sync: true);
  final _positionController = StreamController<Duration>.broadcast(sync: true);
  final _durationController = StreamController<Duration>.broadcast(sync: true);

  PlayerState _state = PlayerState.stopped;
  double _playbackRate = 1.0;

  @override
  Stream<PlayerState> get onPlayerStateChanged => _stateController.stream;

  @override
  Stream<Duration> get onPositionChanged => _positionController.stream;

  @override
  Stream<Duration> get onDurationChanged => _durationController.stream;

  @override
  Stream<void> get onPlayerComplete => _completeController.stream;

  @override
  PlayerState get state => _state;

  @override
  double get playbackRate => _playbackRate;

  @override
  Future<void> setPlaybackRate(double rate) async {
    _playbackRate = rate;
  }

  void triggerComplete() {
    if (!_completeController.isClosed) {
      _completeController.add(null);
    }
  }

  String? lastPlayedAsset;
  int playAssetCallCount = 0;

  @override
  Future<void> playBytes(Uint8List bytes, {String? mimeType, double? playbackRate}) async {
    _state = PlayerState.playing;
    if (playbackRate != null) _playbackRate = playbackRate;
    if (!_stateController.isClosed) _stateController.add(_state);
  }

  @override
  Future<void> playAsset(String assetPath) async {
    lastPlayedAsset = assetPath;
    playAssetCallCount++;
    _state = PlayerState.playing;
    if (!_stateController.isClosed) _stateController.add(_state);
  }

  @override
  Future<void> pause() async {
    _state = PlayerState.paused;
    if (!_stateController.isClosed) _stateController.add(_state);
  }

  @override
  Future<void> resume() async {
    _state = PlayerState.playing;
    if (!_stateController.isClosed) _stateController.add(_state);
  }

  @override
  Future<void> stop() async {
    _state = PlayerState.stopped;
    if (!_stateController.isClosed) _stateController.add(_state);
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> dispose() async {
    if (!_completeController.isClosed) await _completeController.close();
    if (!_stateController.isClosed) await _stateController.close();
    if (!_positionController.isClosed) await _positionController.close();
    if (!_durationController.isClosed) await _durationController.close();
  }
}