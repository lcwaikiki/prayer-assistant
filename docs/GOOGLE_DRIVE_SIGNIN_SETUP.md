# Google Drive Sign-In Setup (from scratch)

How to configure Google Cloud Console and Google Play Console so Google Drive backup sign-in works for debug, sideloaded release, and Play Store builds. Values below are the ones in use for Prayer Assist (verified 2026-10-15).

## Current values

| Item | Value |
|---|---|
| Package name | `com.pirci.prayer_assistant` |
| Cloud project name / ID | `pirci company` / `pirci-company` |
| Cloud project number | `354140926074` |
| **Web client ID** (`GOOGLE_SERVER_CLIENT_ID`) | `354140926074-fucpuug0aksfrsjn6d7qcpn65k07kr43.apps.googleusercontent.com` |

| Android client | Client ID | SHA-1 | Key |
|---|---|---|---|
| Android Debug | `354140926074-gs8crnha9eb30qkrq0jgv7kgbbp1vuh8.apps.googleusercontent.com` | `98:F5:94:30:F1:E4:E5:5E:42:58:10:E1:FE:CD:B8:12:A8:D1:0C:BB` | Debug key (`CN=Android Debug`) |
| Android Upload | `354140926074-9mcaud4k5ntcr6hfjann8j09g74cvh4l.apps.googleusercontent.com` | `64:30:AA:F7:FB:40:B2:23:F8:11:6B:8B:7F:78:CF:B2:22:21:F3:D9` | Upload key (`CN=Osman Pirci`) |
| Android Release | `354140926074-1gdsk8gt12rsrt4q28u9fpdc6rf23mb7.apps.googleusercontent.com` | `75:07:0A:84:BC:04:45:59:79:C3:8C:B3:21:A9:6E:3A:9A:35:57:2F` | Play App Signing key (`CN=Android, O=Google Inc.`) |

## The one rule to remember

| What | Where it goes |
|---|---|
| **Web** client ID `354140926074-fucpuug0...` | `--dart-define=GOOGLE_SERVER_CLIENT_ID=...` in every build/run script |
| **Android** client IDs (`gs8c...`, `9mca...`, `1gds...`) | Only in Cloud Console. Never in the app. Google matches them automatically by package name + SHA-1. |

Passing an Android client ID as `GOOGLE_SERVER_CLIENT_ID` fails with `UNREGISTERED_ON_API_CONSOLE` ("This android application is not registered to use OAuth2.0").

## Signing keys and builds

| Build | How it is made | Signed with | Matched by Android client |
|---|---|---|---|
| Debug | `scripts/run.bat` (`flutter run`) | `%USERPROFILE%\.android\debug.keystore` | Android Debug |
| Sideloaded release | `scripts/build.bat` then `adb install` | `android/app/upload-keystore.jks` (alias `upload`) | Android Upload |
| Play Store / testing tracks | `scripts/build_bundle.bat` then upload to Play | Play App Signing key (Google re-signs) | Android Release |

All three use the same Web client ID.

## Step 1: Create the Cloud project

1. Open https://console.cloud.google.com and sign in with the account that owns the app (the one that can open project `pirci-company`).
2. Create a project: name `pirci company`, ID `pirci-company`. Google assigns the project number (`354140926074`); every client ID starts with it.

## Step 2: Enable the Drive API

APIs & Services > Library > search **Google Drive API** > **Enable**.

## Step 3: Configure Google Auth Platform (consent screen)

Open **Google Auth Platform**: https://console.cloud.google.com/auth/overview?project=pirci-company

1. **Branding**: app name `Prayer Assist`, support email, logo, privacy policy URL, developer contact.
2. **Audience**: User type **External**.
   - While in **Testing**, only listed **Test users** can sign in. Add your accounts there.
   - Click **Publish app** when ready for everyone.
3. **Data Access** > Add or remove scopes > add `https://www.googleapis.com/auth/drive.file`. This scope is non-sensitive, so no Google verification is needed.

## Step 4: Create the Web client (the server client ID)

Google Auth Platform > **Clients** > **Create client**:

- Application type: **Web application**
- Name: `Prayer Assist Web`
- No redirect URIs or origins needed.

Result: `354140926074-fucpuug0aksfrsjn6d7qcpn65k07kr43.apps.googleusercontent.com`. This is the value for `GOOGLE_SERVER_CLIENT_ID`.

## Step 5: Get the SHA-1 fingerprints

**Debug key** (created automatically by the Android SDK):

```
keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android
```

Expected: `SHA1: 98:F5:94:30:F1:E4:E5:5E:42:58:10:E1:FE:CD:B8:12:A8:D1:0C:BB`

**Upload key** (`android/app/upload-keystore.jks`, alias `upload`):

```
keytool -list -v -alias upload -keystore android/app/upload-keystore.jks
```

Expected: `SHA1: 64:30:AA:F7:FB:40:B2:23:F8:11:6B:8B:7F:78:CF:B2:22:21:F3:D9`

If you ever need a new upload key (this changes the SHA-1, so update the Android Upload client and Play Console):

```
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`android/key.properties` (git-ignored, never commit it):

```
storePassword=<your password>
keyPassword=<your password>
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

**Play App Signing key**: available only after the first upload (Step 7). Play Console > Prayer Assist > App integrity > Play app signing > **App signing key certificate** > SHA-1.

Expected: `75:07:0A:84:BC:04:45:59:79:C3:8C:B3:21:A9:6E:3A:9A:35:57:2F`

## Step 6: Create the Android clients

Google Auth Platform > **Clients** > **Create client**, application type **Android**, once per key:

| Name | Package name | SHA-1 |
|---|---|---|
| `Android Debug` | `com.pirci.prayer_assistant` | `98:F5:94:30:F1:E4:E5:5E:42:58:10:E1:FE:CD:B8:12:A8:D1:0C:BB` |
| `Android Upload` | `com.pirci.prayer_assistant` | `64:30:AA:F7:FB:40:B2:23:F8:11:6B:8B:7F:78:CF:B2:22:21:F3:D9` |
| `Android Release` | `com.pirci.prayer_assistant` | `75:07:0A:84:BC:04:45:59:79:C3:8C:B3:21:A9:6E:3A:9A:35:57:2F` (after Step 7) |

You do not copy these client IDs anywhere. Changes can take 5 minutes to a few hours to take effect.

## Step 7: Set up Google Play Console

1. Open https://play.google.com/console with the developer account, create the app with package `com.pirci.prayer_assistant`.
2. Keep **Play App Signing** enabled (default). Google generates the app signing key; your upload key only proves uploads come from you.
3. Build and upload the first bundle to a testing track (internal testing is fastest):
   ```
   scripts\build_bundle.bat
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`.
4. Copy the **App signing key certificate** SHA-1 and finish the `Android Release` client from Step 6.

## Step 8: Build scripts

All scripts use the **Web** client ID:

```
REM scripts/run.bat
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=354140926074-fucpuug0aksfrsjn6d7qcpn65k07kr43.apps.googleusercontent.com %*

REM scripts/build.bat
flutter build apk --release --dart-define=GOOGLE_SERVER_CLIENT_ID=354140926074-fucpuug0aksfrsjn6d7qcpn65k07kr43.apps.googleusercontent.com %*

REM scripts/build_bundle.bat
flutter build appbundle --release --dart-define=GOOGLE_SERVER_CLIENT_ID=354140926074-fucpuug0aksfrsjn6d7qcpn65k07kr43.apps.googleusercontent.com %*
```

Bump `version:` in `pubspec.yaml` (the `+N` build number) before each Play upload.

## Step 9: Verify on a device

1. Install the build (`scripts\run.bat`, `adb install -r build/app/outputs/flutter-apk/app-release.apk`, or from Play).
2. Preferences > Backup & Export > **Sign in to Google Drive** > pick an account.
3. Success: the row changes to **Sign out of Google Drive** with the account email.

## Troubleshooting

Capture the log while signing in:

```
adb logcat -c
adb logcat -v time | findstr /i "GetTokenResponseHandler cvtf CredentialManager"
```

| Log message | Cause | Fix |
|---|---|---|
| `UNREGISTERED_ON_API_CONSOLE` / "not registered to use OAuth2.0" | Android client ID used as server ID, or no Android client for the installed APK's SHA-1 | Use the Web ID `fucpuug0...` in scripts; add an Android client for the right key |
| Sign-in works only for some accounts | Audience still in Testing | Add the account as test user, or publish the app |
| `BAD_AUTHENTICATION` from `com.google.android.gms` | Device Google account needs re-login | Settings > Accounts on the device |

**Check which client ID is compiled into an APK** (must print only `fucpuug0...`):

```
unzip -o build/app/outputs/flutter-apk/app-release.apk "lib/*/libapp.so" -d apkx
grep -a -o "354140926074-[a-z0-9]*\.apps\.googleusercontent\.com" -r apkx | sort -u
```

**Check which key signed the installed app:**

```
adb shell pm path com.pirci.prayer_assistant
adb pull <path-to-base.apk> installed.apk
apksigner verify --print-certs --max-sdk-version 36 installed.apk
```

| Signer SHA-1 | Meaning |
|---|---|
| `75:07:0A:84:...:57:2F` (`CN=Android, O=Google Inc.`) | Installed from Play |
| `64:30:AA:F7:...:F3:D9` (`CN=Osman Pirci`) | Sideloaded release build |
| `98:F5:94:30:...:0C:BB` (`CN=Android Debug`) | Debug build |

`apksigner` is in `%LOCALAPPDATA%\Android\Sdk\build-tools\<version>\`. `--max-sdk-version 36` skips the post-quantum signer some JDKs cannot parse.
