import 'package:flutter/services.dart';

/// Stores a full backup JSON file in a user-picked folder through the Storage
/// Access Framework. The folder lives in user storage, so the file survives an
/// app uninstall and needs no network.
class OfflineFolderBackupService {
  static const _channel = MethodChannel('prayer_assistant/backup_folder');

  /// Fixed file name the app writes and reads inside the chosen folder.
  static const String fileName = 'prayer_assistant_backup.json';

  /// Opens the system folder picker and returns the chosen tree URI, or null
  /// when the user cancels.
  Future<String?> pickFolder() => _channel.invokeMethod<String>('pickFolder');

  /// Returns the persisted folder tree URI, or null when none is set.
  Future<String?> currentFolder() => _channel.invokeMethod<String>('hasFolder');

  /// Forgets the chosen folder and releases its persisted permission.
  Future<void> clearFolder() => _channel.invokeMethod<void>('clearFolder');

  /// Writes [json] to the chosen folder, overwriting the previous backup.
  Future<bool> writeBackup(String json) async {
    final ok = await _channel.invokeMethod<bool>('writeBackup', {
      'content': json,
      'fileName': fileName,
    });
    return ok ?? false;
  }

  /// Reads the backup file from the chosen folder, or null when none exists.
  Future<String?> readBackup() =>
      _channel.invokeMethod<String>('readBackup', {'fileName': fileName});

  /// True when the shared Documents folder exists, so it can be used by
  /// default without asking the user to pick it.
  Future<bool> documentsFolderAvailable() async {
    final available =
        await _channel.invokeMethod<bool>('documentsFolderAvailable');
    return available ?? false;
  }

  /// Writes [json] to the shared Documents folder without a permission prompt.
  Future<bool> writeDocumentsBackup(String json) async {
    final ok = await _channel.invokeMethod<bool>('writeDocumentsBackup', {
      'content': json,
      'fileName': fileName,
    });
    return ok ?? false;
  }

  /// Reads the backup file from the shared Documents folder, or null.
  Future<String?> readDocumentsBackup() => _channel
      .invokeMethod<String>('readDocumentsBackup', {'fileName': fileName});

  /// Human-readable folder label derived from a SAF tree URI.
  static String displayName(String uri) {
    try {
      final segment = Uri.parse(uri).pathSegments.last;
      final decoded = Uri.decodeComponent(segment);
      final index = decoded.indexOf(':');
      return index >= 0 ? decoded.substring(index + 1) : decoded;
    } catch (_) {
      return uri;
    }
  }
}
