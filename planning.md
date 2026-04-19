# Flutter Upgrade Migration Plan

Migration from **Flutter 3.13.0 / Dart 3.1.0** to the latest stable Flutter version.

## Current Baseline

| Component | Current Version |
|---|---|
| Flutter | 3.13.0 (Aug 2023) |
| Dart | 3.1.0 |
| Java | 11 (forced via `flutter config --jdk-dir`) |
| Gradle | 7.4 |
| Android Gradle Plugin | 7.3.1 |
| Kotlin | 1.7.10 |
| compileSdk / targetSdk | 33 |
| minSdk | 21 |
| iOS deployment target | (check ios/Podfile) |

## Target Baseline

| Component | Target Version |
|---|---|
| Flutter | latest stable |
| Dart | matches Flutter (3.5+) |
| Java | 17 |
| Gradle | 8.x |
| Android Gradle Plugin | 8.x |
| Kotlin | 1.9+ |
| compileSdk / targetSdk | 34+ |
| minSdk | 23 (Firebase 3.x requirement) |

---

## Phase 0 — Pre-flight

- [ ] Commit the current working state
- [ ] Snapshot `pubspec.lock` (copy to `pubspec.lock.backup`) for reference
- [ ] Document current build numbers / signing setup
- [ ] Run the app once on Android + iOS and note golden-path flows for later regression testing
- [ ] Ensure a clean `flutter test` run on the baseline

## Phase 1 — Upgrade Flutter SDK

- [ ] `flutter channel stable`
- [ ] `flutter upgrade`
- [ ] `flutter --version` → confirm new Dart + Flutter versions
- [ ] `flutter doctor -v` → fix any environment issues (Xcode, Android SDK, CocoaPods)
- [ ] Remove `flutter config --jdk-dir` override if Flutter now defaults to Java 17 — Flutter bundles a JDK check with `flutter doctor`
- [ ] Update `environment.sdk` in [pubspec.yaml:22](pubspec.yaml#L22) to match the new Dart: `sdk: ">=3.5.0 <4.0.0"` (adjust to actual)

## Phase 2 — Android Toolchain (Gradle / AGP / Kotlin)

All changes in [android/](android/).

- [ ] [android/gradle/wrapper/gradle-wrapper.properties](android/gradle/wrapper/gradle-wrapper.properties): bump to Gradle 8.x (match what AGP 8.x needs — typically 8.7+)
- [ ] [android/build.gradle](android/build.gradle):
  - [ ] Kotlin → `1.9.22` (or newer)
  - [ ] AGP → `com.android.tools.build:gradle:8.x.x`
  - [ ] `google-services` → `4.4.2`
- [ ] [android/app/build.gradle](android/app/build.gradle):
  - [ ] `compileSdkVersion 34`, `targetSdkVersion 34`
  - [ ] Add `namespace "com.yaumi.qurantafsir.id"` inside `android { }`
  - [ ] Bump `minSdkVersion` to 23 (Firebase 3.x requires it)
  - [ ] `sourceCompatibility` / `targetCompatibility` → `JavaVersion.VERSION_17`
  - [ ] `kotlinOptions.jvmTarget` → `'17'`
- [ ] Migrate plugins block to declarative (optional — only if Flutter's new template uses it; follow [docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply](https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply))
- [ ] [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml): remove `package="..."` attribute (now set via `namespace`)
- [ ] Ensure Java 17 is available: `brew install openjdk@17` if needed

## Phase 3 — iOS Toolchain

- [ ] [ios/Podfile](ios/Podfile): raise `platform :ios` to `'13.0'` (Firebase / many plugins require it)
- [ ] [ios/Runner.xcodeproj/project.pbxproj](ios/Runner.xcodeproj/project.pbxproj): confirm `IPHONEOS_DEPLOYMENT_TARGET` ≥ 13.0 in all build configs
- [ ] `cd ios && pod deintegrate && pod install --repo-update`
- [ ] Open in Xcode → resolve any "Update to recommended settings" prompts

## Phase 4 — Dependency Upgrade (pubspec.yaml)

Upgrade in the order below — each group stabilizes the next.

### 4a. Replace discontinued packages

- [ ] `wakelock: ^0.6.2` → `wakelock_plus: ^1.x`
  - Code change: `import 'package:wakelock/wakelock.dart'` → `wakelock_plus/wakelock_plus.dart`
  - `Wakelock.enable() / disable()` → `WakelockPlus.enable() / disable()`
  - Occurrence: [lib/pages/surat_page_v3/surat_page_v3.dart:34,103,128](lib/pages/surat_page_v3/surat_page_v3.dart#L34)
- [ ] `firebase_dynamic_links` is **discontinued** (sunset Aug 2025). Options:
  - Migrate to [app_links](https://pub.dev/packages/app_links) + Firebase Hosting redirects, or
  - Use Branch.io / Adjust, or
  - Implement native deep-linking with custom URL scheme + App Links / Universal Links
  - Audit callers: `grep -r "firebase_dynamic_links" lib/`
- [ ] `dart_code_metrics: ^5.7.6` is **discontinued**. Replace with:
  - `dart_code_metrics_presets` (dev-only) + `custom_lint`, or
  - Just drop it and lean on `flutter_lints` / `very_good_analysis`
- [ ] `alice: ^0.3.2` → latest `alice: ^1.x` (API may have changed — check network interceptor wiring)

### 4b. Firebase stack (upgrade together)

- [ ] `firebase_core: ^3.x`
- [ ] `firebase_analytics: ^11.x`
- [ ] `firebase_crashlytics: ^4.x`
- [ ] `firebase_remote_config: ^5.x`
- [ ] Run `flutterfire configure` to regenerate `firebase_options.dart`
- [ ] Verify `google-services.json` / `GoogleService-Info.plist` still valid

### 4c. Plugins with known breaking changes

- [ ] `package_info_plus: ^3.1.2` → `^8.x` (removes `package` attribute issue)
- [ ] `flutter_local_notifications: ^12.0.4` → `^17.x` — review breaking changes in [changelog](https://pub.dev/packages/flutter_local_notifications/changelog); permission model changed, exact-alarm permission on Android 12+
- [ ] `geolocator: ^10.1.0` → `^13.x`
- [ ] `connectivity_plus: ^4.0.2` → `^6.x`
- [ ] `permission_handler` (if used indirectly)
- [ ] `google_sign_in: ^6.1.4` → latest (API changed significantly in 7.x — may require code changes)
- [ ] `sign_in_with_apple: ^5.0.0` → latest
- [ ] `http: ^0.13.6` → `^1.x` (alice 1.x requires this)
- [ ] `dio: ^4.0.6` → `^5.x` (breaking: `BaseOptions`, interceptor signatures, `ResponseType`)
  - Check all files using `Dio()`, `Interceptor`, `DioError` → renamed to `DioException`
- [ ] `retrofit: ^3.3.1` + `retrofit_generator: ^4.2.0` → latest matching pair
- [ ] `pretty_dio_logger: ^1.2.0-beta-1` → latest stable
- [ ] `workmanager: 0.5.0` → `^0.5.2+` (pin exact version is risky; use caret)
- [ ] `audio_service: ^0.18.9`, `just_audio: ^0.9.32` → latest
- [ ] `intl: ^0.18.1` → `^0.19.x` (Flutter upgrades often force this)
- [ ] `shared_preferences: ^2.0.15` → latest
- [ ] `path_provider: ^2.0.4` → latest
- [ ] `uuid: ^3.0.7` → `^4.x` (API: `Uuid().v4()` unchanged, but some constants moved)

### 4d. Generator packages (dev_dependencies)

- [ ] `flutter_lints: ^2.0.2` → `^4.x`
- [ ] `build_runner: ^2.1.7` → latest
- [ ] `json_serializable: ^6.5.4` → latest
- [ ] `retrofit_generator` → match runtime retrofit version
- [ ] After upgrade: `dart run build_runner build --delete-conflicting-outputs`

## Phase 5 — Code Migration

### 5a. Compile / analyze cleanup

- [ ] `flutter analyze` — fix all errors, then warnings, then info
- [ ] Address deprecations flagged in IDE diagnostics (e.g. `theme.dart` → `QPColors` / `QPTextStyle` noted in [lib/pages/surat_page_v3/surat_page_v3.dart:27](lib/pages/surat_page_v3/surat_page_v3.dart#L27))
- [ ] Dart 3 class modifiers — if any `abstract class` is instantiated, add `base` / `final` / `sealed` as appropriate
- [ ] `DioError` → `DioException` throughout `lib/`
- [ ] Replace `WillPopScope` with `PopScope` (Flutter 3.16+)
- [ ] Replace deprecated `Share.share` (if using `share_plus`) → `SharePlus.instance.share(...)`
- [ ] Review `MaterialStateProperty` → `WidgetStateProperty` (Flutter 3.22+)
- [ ] `ThemeData.useMaterial3` — decide whether to opt into Material 3 or keep M2 with `useMaterial3: false`

### 5b. Platform channel / native code

- [ ] Android: verify any custom Kotlin/Java code in `android/app/src/main/kotlin/` still compiles (JVM 17)
- [ ] iOS: verify custom Swift in `ios/Runner/` still compiles on latest Xcode

### 5c. Asset / font sanity

- [ ] No change expected — Flutter's font loader is stable. Just spot-check that the 600+ Quran page fonts still load after upgrade.

## Phase 6 — Verification

### 6a. Build

- [ ] `flutter clean && rm -rf ~/.gradle/caches`
- [ ] `flutter pub get`
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter build apk --debug` — Android debug builds
- [ ] `flutter build apk --release` — Android release builds (catches R8/Proguard issues)
- [ ] `flutter build ios --debug` (no codesign OK locally)
- [ ] `flutter build ios --release`

### 6b. Functional regression (run on device)

Test the golden paths noted in Phase 0, plus:

- [ ] App launch + splash
- [ ] Login (Google / Apple sign-in)
- [ ] Quran page navigation (font rendering across all 600+ pages)
- [ ] Audio playback (`just_audio` + `audio_service`) — foreground + lock screen
- [ ] Bookmarks / favorites persistence (`sqflite` + `shared_preferences`)
- [ ] Local notifications (prayer reminder) — **especially on Android 14+** (exact alarm permission model changed)
- [ ] Background tasks (`workmanager`) — prayer time reminder
- [ ] Deep links (post `firebase_dynamic_links` replacement)
- [ ] Firebase Analytics events still fire (check DebugView)
- [ ] Crashlytics — force a test crash and verify dashboard receives it
- [ ] Remote Config — verify keys fetch
- [ ] Geolocation for prayer times
- [ ] HTTP / Dio API calls (Alice debug overlay works)

### 6c. CI / release artifact

- [ ] Update any CI workflow referencing Java 11 → Java 17
- [ ] Update any workflow referencing old Flutter version
- [ ] Bump `version:` in [pubspec.yaml:19](pubspec.yaml#L19) and build number

## Phase 7 — Rollout

- [ ] Internal test track / TestFlight first
- [ ] Monitor Crashlytics for 48h before public rollout
- [ ] Staged rollout on Play Store (10% → 50% → 100%)

---

## Known Cascading Pitfalls (from earlier debugging session)

- **AGP 8 + old plugins**: plugins that declare `package=...` in their `AndroidManifest.xml` break. Most are fixed by upgrading the plugin — do not patch the pub cache.
- **Firebase peer deps**: `firebase_crashlytics X` → `firebase_core ^Y` → `firebase_core_web ^Z` → Dart SDK floor. Always upgrade the Firebase stack as a unit.
- **`win32` conflict**: `wakelock` pins `win32 ^3`, `package_info_plus ^4+` needs `win32 >=4`. Migrating to `wakelock_plus` resolves it.
- **`alice ^0.4+` pins `http ^1`**: so `http` must be bumped alongside.
- **Java mismatch**: Flutter's bundled Gradle/AGP must match the JDK Flutter runs against. `flutter doctor` reports the JDK in use.

## Rollback Plan

If migration blocks a release:
- Revert to the branch point: `git checkout master`
- `flutter channel stable && flutter downgrade <previous-version>`
- `flutter config --jdk-dir="/usr/local/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"` to restore Java 11
- `flutter clean && flutter pub get`
