# Upgrade Plan — Hashgen Mobile

## Current state

Score: 7.5/10 — digests/HMAC/compare with tool-format paste support and explanatory errors, a11y guideline tests and fail-closed signing; no file hashing, icon or E2E flow yet.

## Backlog

### P0
- None open. (Release signing now fails closed without `android/key.properties`.)

### P1
- Hash a picked file (streamed) in addition to text.
- Replace the template launcher icon with a real app icon (the application ID `com.bookchaowalit.*` is already set).
- Add a Maestro smoke flow for the main journey.
- Add a CI job that builds a signed release bundle from repository secrets (keystore decoded at runtime, never committed).

### P2
- Tablet layout (NavigationRail).
- Localisation (Thai/English) for UI strings.

## Done in this pass (pass 3)

- Bug fix: comparing against a digest pasted straight from a tool always said "No match" — `sha256sum` (`<hex>  file`), BSD `SHA256 (file) = <hex>` and `sha256:<hex>` kept the extra text. When exactly one hex run of a supported length is present it is now used as the digest.
- Error state: a non-matching comparison now says why when the input cannot be a digest ("8 hex characters; expected 32 (MD5), 40 …", "Not a hex digest"); in HMAC mode the match reads "Matches HMAC-SHA-256". The result is a live region.
- Edge-case unit tests: tool paste formats, truncated/over-long/ambiguous pastes, format problems, empty-key HMAC, RFC 4231 test case 1, emoji/Thai UTF-8 input, empty SHA-512. Widget tests: format explanation and HMAC match from a `sha256sum`-style paste, copy to clipboard, a11y guidelines, 200% text scale at phone width. (Copy buttons already existed; P1 item removed.)

## Done in pass 2

- Release builds no longer sign with the debug key: `android/app/build.gradle.kts` reads the ignored `android/key.properties` and a Gradle guard fails any release assemble/bundle without it (pattern from `bookchaowalit-goal-tracker-mobile`). Root `.gitignore` also ignores `key.properties`, `*.jks`, `*.keystore`; README documents the setup. Not build-verified here (no Android SDK/Gradle in this environment).


## Done in pass 1

- Replaced the Expo/npm CI (which could never fail) with fail-closed Flutter CI: `dart format` check, `flutter analyze`, `flutter test`, debug APK on `main`.
- Implemented the core feature (generate md5, sha-1, sha-256 and sha-512 digests of text) with pure-Dart logic in `lib/logic/`.
- Replaced placeholder Explore/Profile tabs with an About screen describing features and privacy.
- Added unit tests for the logic and widget tests for the main journey.
- Removed unused `go_router` / `flutter_riverpod` dependencies; README now matches the code.
