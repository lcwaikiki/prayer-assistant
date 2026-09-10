import 'dart:async';
import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleDriveBackupService {
  static const _scopes = [drive.DriveApi.driveFileScope];
  static const _folderName = 'Prayer Assistant';
  static const _fileName = 'prayer_assistant_backup.json';

  /// Web OAuth 2.0 client ID of the app's backend. Required on Android.
  /// Provide it at build time:
  ///   flutter build --dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com
  static const _serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;
  bool _signedIn = false;
  String? _accountEmail;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSub;

  bool get isSignedIn => _signedIn;

  String? get accountEmail => _accountEmail;

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

  /// Signs in and authorizes Drive access.
  ///
  /// Uses the standard sign-in flow to obtain the account, falling back to the
  /// authorization client if Credential Manager's getCredential fails (e.g.
  /// "[16] Account reauth failed" on Android 16).
  Future<bool> signIn() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
    _accountEmail = null;
    try {
      final account = await _googleSignIn.authenticate(scopeHint: _scopes);
      _accountEmail = account.email;
      _signedIn = true;
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
  }

  Future<drive.DriveApi> _driveApi() async {
    await _ensureInitialized();
    final authorization =
        await _googleSignIn.authorizationClient.authorizeScopes(_scopes);
    return drive.DriveApi(
      authorization.authClient(scopes: _scopes),
    );
  }

  Future<String> uploadBackup(String jsonContent) async {
    final api = await _driveApi();
    final folderId = await _getOrCreateFolder(api);
    final existingFileId = await _findExistingBackup(api, folderId);

    final bytes = utf8.encode(jsonContent);
    final media = drive.Media(Stream.value(bytes), bytes.length);

    if (existingFileId != null) {
      final updated = drive.File()..name = _fileName;
      await api.files.update(
        updated,
        existingFileId,
        uploadMedia: media,
      );
      return existingFileId;
    } else {
      final file = drive.File()
        ..name = _fileName
        ..parents = [folderId];
      final created = await api.files.create(
        file,
        uploadMedia: media,
      );
      return created.id!;
    }
  }

  Future<String?> downloadBackup() async {
    final api = await _driveApi();
    final fileId = await _findAnyBackup(api);
    if (fileId == null) {
      return null;
    }

    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = await media.stream.expand((chunk) => chunk).toList();
    return utf8.decode(bytes);
  }

  Future<DateTime?> getLastBackupTime() async {
    final api = await _driveApi();
    final fileId = await _findAnyBackup(api);
    if (fileId == null) return null;

    final file = await api.files.get(
      fileId,
      $fields: 'modifiedTime',
    ) as drive.File;

    return file.modifiedTime;
  }

  Future<String?> _findAnyBackup(drive.DriveApi api) async {
    final query = "name='$_fileName' and trashed=false";
    final result = await api.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id)',
    );
    if (result.files == null || result.files!.isEmpty) return null;
    return result.files!.first.id;
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

  Future<String?> _findExistingBackup(
    drive.DriveApi api,
    String folderId,
  ) async {
    final query =
        "name='$_fileName' and '$folderId' in parents and trashed=false";
    final result = await api.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id)',
    );
    if (result.files == null || result.files!.isEmpty) return null;
    return result.files!.first.id;
  }
}