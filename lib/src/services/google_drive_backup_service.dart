import 'dart:async';
import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_export_service.dart';

/// A single backup file stored on Google Drive.
class DriveBackupInfo {
  const DriveBackupInfo({
    required this.fileId,
    required this.createdTime,
    required this.itemCount,
    required this.fileName,
  });

  final String fileId;
  final DateTime createdTime;
  final int itemCount;
  final String fileName;
}

class GoogleDriveBackupService {
  static const _scopes = [drive.DriveApi.driveFileScope];
  static const _folderName = 'Prayer Assistant';
  static const _backupNamePrefix = 'prayer_assistant_backup';
  static const _emailPrefsKey = 'google_drive_account_email';
  static const _listLimitPrefsKey = 'google_drive_backup_list_limit';
  static const _alwaysKeepCount = 10;
  static const _retentionDays = 90;

  /// Web OAuth 2.0 client ID of the app's backend. Required on Android.
  /// Provide it at build time:
  ///   flutter build --dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com
  static const _serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;
  bool _signedIn = false;
  String? _accountEmail;
  int _listLimit = 10;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSub;

  bool get isSignedIn => _signedIn;

  String? get accountEmail => _accountEmail;

  /// Number of backups to show in the restore list. Negative means all.
  int get listLimit => _listLimit;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _googleSignIn.initialize(
        serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
      );
      _authSub ??= _googleSignIn.authenticationEvents.listen((event) {
        switch (event) {
          case GoogleSignInAuthenticationEventSignIn():
            _signedIn = true;
          case GoogleSignInAuthenticationEventSignOut():
            _signedIn = false;
        }
      });
      _initialized = true;
    }
  }

  /// Restores the previously persisted sign-in state without prompting.
  ///
  /// The account email is loaded from local preferences immediately. A silent
  /// authorization probe refreshes the session when possible; when the token
  /// is gone the optimistic state is kept and the next Drive operation will
  /// request authorization itself.
  Future<void> restoreSession() async {
    await _ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    _accountEmail = prefs.getString(_emailPrefsKey);
    _signedIn = _accountEmail != null;
    _listLimit = prefs.getInt(_listLimitPrefsKey) ?? 10;
    try {
      await _googleSignIn.authorizationClient.authorizationForScopes(_scopes);
    } catch (_) {
      // keep optimistic state; operations re-authorize on demand.
    }
  }

  Future<void> setListLimit(int limit) async {
    _listLimit = limit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_listLimitPrefsKey, limit);
  }

  /// Signs in and authorizes Drive access.
  ///
  /// Uses the standard sign-in flow to obtain the account, falling back to the
  /// authorization client if Credential Manager's getCredential fails (e.g.
  /// "[16] Account reauth failed" on Android 16).
  Future<bool> signIn() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
    await _persistEmail(null);
    try {
      final account = await _googleSignIn.authenticate(scopeHint: _scopes);
      _accountEmail = account.email;
      _signedIn = true;
      await _persistEmail(_accountEmail);
      return true;
    } on GoogleSignInException catch (e) {
      final canFallback = e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted ||
          e.code == GoogleSignInExceptionCode.uiUnavailable;
      if (!canFallback) {
        rethrow;
      }
      try {
        await _googleSignIn.authorizationClient.authorizeScopes(_scopes);
        _signedIn = true;
        await _persistEmail(_accountEmail);
        return true;
      } on GoogleSignInException catch (fallbackError) {
        if (fallbackError.code == GoogleSignInExceptionCode.canceled ||
            fallbackError.code == GoogleSignInExceptionCode.interrupted ||
            fallbackError.code == GoogleSignInExceptionCode.uiUnavailable) {
          return false;
        }
        rethrow;
      }
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
    _signedIn = false;
    _accountEmail = null;
    await _persistEmail(null);
  }

  Future<void> _persistEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove(_emailPrefsKey);
    } else {
      await prefs.setString(_emailPrefsKey, email);
    }
  }

  /// Returns a Drive API client, silently reusing a stored authorization when
  /// possible and only prompting for authorization when the session is gone.
  Future<drive.DriveApi> _driveApi() async {
    await _ensureInitialized();
    var authorization = await _googleSignIn.authorizationClient
        .authorizationForScopes(_scopes);
    authorization ??= await _googleSignIn.authorizationClient
        .authorizeScopes(_scopes);
    return drive.DriveApi(authorization.authClient(scopes: _scopes));
  }

  /// Uploads the given backup JSON as a new timestamped file.
  ///
  /// Then applies retention: files older than 3 months that are beyond the
  /// newest 10 backups are deleted. The newest 10 backups are always kept.
  Future<String> uploadBackup(String jsonContent) async {
    final api = await _driveApi();
    final folderId = await _getOrCreateFolder(api);

    final bytes = utf8.encode(jsonContent);
    final file = drive.File()
      ..name = _newBackupName()
      ..parents = [folderId];
    final created = await api.files.create(
      file,
      uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
    );
    await _applyRetention(api);
    return created.id!;
  }

  String _newBackupName() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final stamp = '${now.year}${two(now.month)}${two(now.day)}'
        '_${two(now.hour)}${two(now.minute)}${two(now.second)}';
    return '${_backupNamePrefix}_$stamp.json';
  }

  /// Lists the stored backups newest first, limited by [listLimit].
  Future<List<DriveBackupInfo>> listBackups() async {
    final api = await _driveApi();
    final all = await _listBackupFiles(api);
    final selected = _listLimit < 0 || all.length <= _listLimit
        ? all
        : all.sublist(0, _listLimit);
    final result = <DriveBackupInfo>[];
    for (final file in selected) {
      result.add(
        DriveBackupInfo(
          fileId: file.id!,
          createdTime: file.createdTime ?? DateTime.fromMillisecondsSinceEpoch(0),
          itemCount: await _countItemsInFile(api, file.id!),
          fileName: file.name ?? '',
        ),
      );
    }
    return result;
  }

  Future<List<drive.File>> _listBackupFiles(drive.DriveApi api) async {
    final folderId = await _getOrCreateFolder(api);
    final result = await api.files.list(
      q:
          "name contains '$_backupNamePrefix' and '$folderId' in parents and trashed=false",
      orderBy: 'createdTime desc',
      pageSize: 100,
      $fields: 'files(id,name,createdTime)',
    );
    return result.files ?? <drive.File>[];
  }

  Future<void> _applyRetention(drive.DriveApi api) async {
    final files = await _listBackupFiles(api);
    final now = DateTime.now();
    for (var i = 0; i < files.length; i++) {
      final created = files[i].createdTime;
      if (i >= _alwaysKeepCount &&
          created != null &&
          now.difference(created) > const Duration(days: _retentionDays)) {
        await api.files.delete(files[i].id!);
      }
    }
  }

  Future<int> _countItemsInFile(drive.DriveApi api, String fileId) async {
    try {
      final media = await api.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      final bytes = await media.stream.expand((chunk) => chunk).toList();
      final raw = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return BackupExportService.countItems(raw);
    } catch (_) {
      return 0;
    }
  }

  /// Downloads the content of a specific backup file.
  Future<String> downloadBackup(String fileId) async {
    final api = await _driveApi();
    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final bytes = await media.stream.expand((chunk) => chunk).toList();
    return utf8.decode(bytes);
  }

  Future<String> _getOrCreateFolder(drive.DriveApi api) async {
    final query =
        "name='$_folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
    final result = await api.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id)',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }

    final folder = drive.File()
      ..name = _folderName
      ..mimeType = 'application/vnd.google-apps.folder';
    final created = await api.files.create(folder);
    return created.id!;
  }
}