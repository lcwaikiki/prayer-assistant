import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

final audioRecorderServiceProvider =
    Provider.autoDispose<AudioRecorderService>((ref) {
  final service = AudioRecorderService();
  ref.onDispose(service.dispose);
  return service;
});

class AudioRecorderService {
  AudioRecorderService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  String? _currentRecordingPath;

  Future<bool> hasPermission() async {
    return _recorder.hasPermission();
  }

  Future<bool> isRecording() async {
    return _recorder.isRecording();
  }

  Future<void> startRecording() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }

    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/rec_${DateTime.now().microsecondsSinceEpoch}.m4a';
    _currentRecordingPath = filePath;

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );
  }

  Future<Uint8List?> stopRecording() async {
    final path = await _recorder.stop();
    final effectivePath = path ?? _currentRecordingPath;
    _currentRecordingPath = null;

    if (effectivePath == null) return null;

    final file = File(effectivePath);
    if (!await file.exists()) return null;

    try {
      final bytes = await file.readAsBytes();
      await file.delete();
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      final path = await _recorder.stop();
      final effectivePath = path ?? _currentRecordingPath;
      _currentRecordingPath = null;
      if (effectivePath != null) {
        final file = File(effectivePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}
    await _recorder.dispose();
  }
}
