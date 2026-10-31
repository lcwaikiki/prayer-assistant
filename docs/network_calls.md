# Network & API Calls

This document details all network and API calls made by the application during cold start and application lifecycle state transitions (such as switching back to the app).

## 1. On Cold Start

Yes, the application performs network requests upon cold start depending on cache state and configuration.

### Always on Cold Start (Background Location Preload)
Even when prayer times are already cached locally in SQLite, the app re-populates its in-memory location tree in `_loadStartupBackgroundData` (`lib/src/controller/prayer_app_controller.dart`):
- `https://ezanvakti.imsakiyem.com/api/locations/countries`
- `https://ezanvakti.imsakiyem.com/api/locations/states?countryId={countryId}`
- `https://ezanvakti.imsakiyem.com/api/locations/districts?stateId={stateId}`

### First Launch / When Yearly Prayer Times Are Not Cached (or New Year)
If the local SQLite database does not have full year data for the selected district (`hasSufficientYearData` check in `refreshPrayerData`):
- `https://ezanvakti.imsakiyem.com/api/prayer-times/{districtId}/yearly?startDate={yyyy}-01-01`

### Fresh Install (No Location Selected Yet)
If no location has ever been selected yet:
- `https://ezanvakti.imsakiyem.com/api/locations/countries`

### Optional (Only If User Signed Into Google Drive Backup)
If Google Drive backup is enabled, the session is restored on startup:
- `https://accounts.google.com`
- `https://oauth2.googleapis.com/token`
- `https://www.googleapis.com/drive/v3/...`

---

## 2. On Switching to App (Resuming from Background)

- **Prayer Times & Location Data:** No network calls are made. The app reads entirely from the local SQLite database and memory caches.
- **Optional Exception (Google Drive Backup Only):** If and only if the user is actively signed in to Google Drive backup, `syncSoundsToDrive()` checks for missing custom sound files:
  - `https://www.googleapis.com/drive/v3/files`

