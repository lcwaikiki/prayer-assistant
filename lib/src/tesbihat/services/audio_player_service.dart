import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

class AudioPlayerService {
  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  double _playbackRate = 1.0;

  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;
  Stream<void> get onPlayerComplete => _player.onPlayerComplete;

  PlayerState get state => _player.state;
  double get playbackRate => _playbackRate;

  Future<void> setPlaybackRate(double rate) async {
    _playbackRate = rate;
    await _player.setPlaybackRate(rate);
  }

  Future<void> playBytes(Uint8List bytes, {String? mimeType, double? playbackRate}) async {
    await _player.stop();
    final source = BytesSource(bytes, mimeType: mimeType);
    await _player.play(source);
    final rate = playbackRate ?? _playbackRate;
    if (rate != 1.0) {
      await _player.setPlaybackRate(rate);
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.resume();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> dispose() async {
    await _player.stop();
    await _player.dispose();
  }
}
