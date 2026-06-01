# PowerAlert Pakistan

PowerAlert Pakistan is a Flutter load shedding tracker for WAPDA DISCO areas in Pakistan. It includes onboarding, schedules, notifications, crowdsourced reports, Firebase integration, AdMob, and a Material 3 light/dark theme.

## Features

- DISCO, division, and feeder/area onboarding
- Today view with current power status and outage countdown
- Weekly schedule with outage summaries
- Firebase Cloud Messaging and local notifications
- Crowdsource reporting for schedule accuracy
- Red "Electricity Gone? Tap to Report" button when the app believes power is on
- Settings for area, notifications, and theme mode
- Banner and interstitial AdMob support
- Offline-aware Firestore usage and cached fallback schedules

## Project Structure

- `lib/main.dart` bootstraps the app
- `lib/core/` contains constants, theme, and utilities
- `lib/data/` contains models, repositories, and services
- `lib/presentation/` contains screens, widgets, and providers
- `lib/notifications/` contains notification exports

## Getting Started

1. Install Flutter 3.22+ and verify it with `flutter --version`.
2. Run `flutter pub get`.
3. Copy or generate your Firebase Android config into `android/app/google-services.json`.
4. Replace the placeholder values in `lib/firebase_options.dart` with your Firebase project values, or generate the file with FlutterFire CLI.
5. Create Firebase Auth, Firestore, Cloud Messaging, and Analytics in your Firebase project.
6. Firestore persistence is enabled in code when Firebase is turned on.
7. Configure AdMob IDs via compile-time defines for production.

## Firebase Setup

The app is written to run in a local fallback mode when Firebase is disabled through compile-time flags. For production:

- Build with `--dart-define=ENABLE_FIREBASE=true`
- Set `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, and `FIREBASE_PROJECT_ID` if you are not using generated FlutterFire options
- Add your `google-services.json` to `android/app/google-services.json`

Use [android/app/google-services.json.example](android/app/google-services.json.example) as a reference and replace it with your real Firebase file before building a production APK.

## Cloud Functions Backend

The repository now includes a Firebase Functions project in [functions/package.json](functions/package.json) and scraper/aggregation logic in [functions/src/index.js](functions/src/index.js).

- A scheduled function runs every 6 hours and scrapes official DISCO websites.
- A manual HTTP trigger is available for admins and can be protected with `ADMIN_TRIGGER_SECRET`.
- Scraped schedules are normalized, deduplicated, validated, and written to Firestore.
- Flagged changes are marked `pending_review` and published to the `admin_alerts` FCM topic.
- New `outage_reports` documents trigger aggregation logic that can mark an area as `unscheduled_outage`.
- Firestore rules are defined in [firestore.rules](firestore.rules).

Deploy with:

```bash
firebase deploy --only functions,firestore:rules
```

## Electricity Gone Report

- The Home screen shows a red report button only when the current system status is `Power ON`.
- The report sheet captures the outage time and optional reason.
- The app rate-limits one report per area for 30 minutes using SharedPreferences.
- Reports are written to `outage_reports/{reportId}` with anonymous auth metadata.

## AdMob Setup

Development uses Google test IDs automatically. For production, supply your own IDs:

```bash
flutter run \
	--dart-define=ADMOB_BANNER_ID=ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx \
	--dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx
```

## Build Flags

- `ENABLE_FIREBASE=true` turns on Firebase initialization
- `ENABLE_ADS=true` enables AdMob initialization
- `ENABLE_ANALYTICS=true` enables Firebase Analytics integration in your codebase when configured

## Firestore Data Model

- `discos/{discoId}/areas/{areaId}/schedules/{weekId}`
- `reports/{reportId}`
- `users/{userId}`

Example schedule document:

```json
{
	"weekStartDate": "2026-06-01T00:00:00.000Z",
	"areaId": "gulberg",
	"discoId": "lesco",
	"slots": [
		{ "day": "Monday", "startTime": "08:00", "endTime": "10:00" },
		{ "day": "Monday", "startTime": "20:00", "endTime": "22:00" }
	]
}
```

## Notes

- The app uses `shared_preferences` to persist onboarding and settings locally.
- Local notifications are scheduled for outage start reminders and restoration alerts.
- Interstitial ads are limited to once per session when switching areas.
- If you want to add the native Android/iOS Flutter platform folders, run `flutter create .` in a Flutter-enabled environment.
