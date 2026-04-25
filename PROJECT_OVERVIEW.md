# Quran Plus — Project Overview

A re-onboarding document for returning developers. Covers what the app is, how it's built, and where performance wins live.

---

## 1. What Is This Project?

**Quran Plus** (pubspec name: `qurantafsir_flutter`, version 1.8.0+103) is a Flutter-based Islamic companion app for the Indonesian Muslim audience. It combines four primary product pillars:

1. **Quran reading** — full mushaf rendering with verse-by-verse translations, tafsirs (exegesis), and audio recitation with background playback
2. **Tadabbur** — long-form reflective content on specific ayahs ("what does this verse mean for me?")
3. **Habit tracking** — personal and group-based Quran reading habits with streaks, daily targets, and social challenges
4. **Prayer times** — location-based daily prayer schedule with scheduled notifications

Design traits worth knowing: **offline-first** (Quran pages, translations, and tafsirs are bundled as SQLite + asset files), **server-sync when logged in** (bookmarks, habits, favorites sync through the Quran Plus backend), and **native integrations** on both iOS (APNs, Sign in with Apple) and Android (foreground audio service, WorkManager).

Build targets: iOS 13+ and Android (minSdk defined in `android/app/build.gradle`). Flutter SDK `>=3.24.0`, Dart `>=3.5.0`.

---

## 2. Feature Map

User-facing feature → where the code lives:

| Feature | Folder |
|---|---|
| Quran reading (mushaf view) | [lib/pages/surat_page_v3/](lib/pages/surat_page_v3/) |
| Tafsir / Tadabbur reading | [lib/pages/read_tadabbur/](lib/pages/read_tadabbur/), [lib/pages/tadabbur_story/](lib/pages/tadabbur_story/) |
| Tadabbur surah list | [lib/pages/tadabbur_surah_list_page/](lib/pages/tadabbur_surah_list_page/) |
| Habit tracking (personal) | [lib/pages/habit_page/habit_progress/widgets/habit_personal/](lib/pages/habit_page/habit_progress/widgets/habit_personal/) |
| Habit group challenges | [lib/pages/habit_page/habit_progress/widgets/habit_group/](lib/pages/habit_page/habit_progress/widgets/habit_group/), [lib/pages/habit_group_detail/](lib/pages/habit_group_detail/) |
| Bookmarks & favorite ayahs | [lib/pages/bookmark_v2/](lib/pages/bookmark_v2/) |
| Prayer times | [lib/pages/prayer_time_page/](lib/pages/prayer_time_page/) |
| Auth (Google / Apple) | [lib/pages/registration_and_login_page/](lib/pages/registration_and_login_page/) |
| Settings | [lib/pages/settings_page/](lib/pages/settings_page/) |
| Home dashboard | [lib/pages/home_page_v2/](lib/pages/home_page_v2/) |
| Splash / boot | [lib/pages/splash_page/](lib/pages/splash_page/) |
| Account deletion flow | [lib/pages/account_deletion/](lib/pages/account_deletion/) |

The 5 bottom-nav tabs are wired in [lib/pages/main_page/main_page.dart:35-41](lib/pages/main_page/main_page.dart#L35-L41): Home, Habit, Tadabbur, Bookmark, Settings.

---

## 3. Framework Stack

Grouped by role. Versions from [pubspec.yaml](pubspec.yaml).

### State management
| Package | Version | Role |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | Primary state management. All business state lives in `StateNotifier` subclasses exposed via `StateNotifierProvider`. |

### Networking
| Package | Version | Role |
|---|---|---|
| `dio` | ^5.7.0 | HTTP client (3 variants in `DioService`: base, access-token, API-key). |
| `retrofit` | ^4.4.1 | Type-safe API client generation from abstract classes. |
| `retrofit_generator` | ^9.1.2 (dev) | Codegen for retrofit. |
| `pretty_dio_logger` | ^1.4.0 | Dev-mode request/response logging. |
| `alice` + `alice_dio` | ^1.0.0-dev.11 / ^1.0.5 | In-app HTTP inspector (shake device to inspect requests in dev). |

### Database & local storage
| Package | Version | Role |
|---|---|---|
| `sqflite` | ^2.3.3+1 | SQLite for Quran pages, translations, tafsirs, bookmarks cache. Single instance in `DbLocal`. |
| `shared_preferences` | ^2.3.2 | Key-value store for user prefs, theme, auth token, onboarding flags. |
| `path` / `path_provider` | ^1.9.0 / ^2.1.4 | File path helpers. |

### Firebase
| Package | Version | Role |
|---|---|---|
| `firebase_core` | ^3.6.0 | Bootstrap. |
| `firebase_crashlytics` | ^4.1.3 | Crash reporting (wired in `main.dart` onError handlers). |
| `firebase_analytics` | ^11.3.3 | Analytics + navigator observer. |
| `firebase_remote_config` | ^5.1.3 | Feature flags / remote config via `RemoteConfigService`. |

### Audio
| Package | Version | Role |
|---|---|---|
| `just_audio` | ^0.9.40 | Audio player engine. |
| `audio_service` | ^0.18.15 | Background audio + notification controls. Initialized in `main()` via `AudioService.init<AudioRecitationHandler>(...)`. |
| `audio_video_progress_bar` | ^2.0.3 | Progress bar UI. |
| `wakelock_plus` | ^1.2.8 | Keep screen on during recitation. |

### Auth
| Package | Version | Role |
|---|---|---|
| `google_sign_in` | ^6.2.1 | Google OAuth. |
| `sign_in_with_apple` | ^6.1.2 | Apple ID sign in (iOS). |

### Background tasks & notifications
| Package | Version | Role |
|---|---|---|
| `workmanager` | ^0.9.0+3 | Native background task runner — schedules prayer-time notifications. |
| `flutter_local_notifications` | ^17.2.3 | Local notification display. |

### Prayer times & location
| Package | Version | Role |
|---|---|---|
| `adhan` | ^2.0.0+1 | Islamic prayer time calculations. |
| `geolocator` | ^13.0.1 | Device GPS. |
| `timezone` | ^0.9.4 | TZ-aware scheduling. |

### UI helpers
| Package | Version | Role |
|---|---|---|
| `cached_network_image` | ^3.4.1 | Network image cache (avatars, etc.). |
| `flutter_svg` | ^2.0.10+1 | SVG asset rendering. |
| `lottie` | ^3.1.2 | Lottie animations (e.g., tracking animation). |
| `shimmer` | ^3.0.0 | Skeleton loading placeholders. |
| `google_fonts` | ^6.2.1 | Fallback web fonts. |
| `percent_indicator` | ^4.2.3 | Circular / linear progress (habits). |
| `auto_size_text` | ^3.0.0 | Auto-fit text. |
| `visibility_detector` | ^0.4.0+2 | Page-visibility tracking in PageView. |
| `scroll_to_index` | ^3.0.1 | Jump-to-index scrolling. |
| `page_transition` | ^2.1.0 | Custom route transitions. |

### Deep linking & misc
| Package | Version | Role |
|---|---|---|
| `app_links` | ^6.3.2 | Universal / app links (share bookmarks, etc.). |
| `connectivity_plus` | ^6.0.5 | Network reachability. |
| `global_configuration` | ^2.0.0-nullsafety.0 | Reads `assets/cfg/env.json`. |
| `package_info_plus` | ^8.0.2 | App version info. |
| `store_redirect` | ^2.0.3 | Rate-in-store / update prompt. |
| `uuid` | ^4.5.1 | ID generation. |
| `intl` | ^0.19.0 | Date/number formatting. |
| `equatable` | ^2.0.5 | Value equality for state classes. |

### Dev tools
| Package | Version | Role |
|---|---|---|
| `build_runner` | ^2.4.13 | Codegen runner. |
| `json_serializable` | ^6.8.0 | `fromJson`/`toJson` codegen. |
| `flutter_lints` | ^4.0.0 | Lint rules (see [analysis_options.yaml](analysis_options.yaml)). |

---

## 4. Architecture at a Glance

**Layering** (top → bottom): `Page Widget` → `StateNotifier` → `Service` → `API (retrofit)` / `DbLocal (sqflite)` / `SharedPreferenceService`.

**Key abstractions**:

- **`BaseStateNotifier<T>`** — in [lib/shared/core/state_notifiers/base_state_notifier.dart](lib/shared/core/state_notifiers/base_state_notifier.dart). Subclasses override `initStateNotifier()` for post-construction setup. Called exactly once from `StateNotifierConnector` or `ConsumerState.initState`.
- **`StateNotifierConnector<N, S>`** — custom widget in [lib/shared/ui/state_notifier_connector.dart](lib/shared/ui/state_notifier_connector.dart). Wraps a page, wires up the provider, calls `initStateNotifier()` after first frame, and rebuilds on state changes. This is the standard page-boilerplate pattern across the app.
- **`DioService`** — [lib/shared/core/services/dio_service.dart](lib/shared/core/services/dio_service.dart). Single HTTP entry point. Provides three `Dio` instances: base (public), with-access-token (authenticated), with-API-key (server-key-protected endpoints). Owns interceptors (auth, logging, alice).
- **`DbLocal`** — [lib/shared/core/database/db_local.dart](lib/shared/core/database/db_local.dart). Singleton SQLite opener + Quran page/translation/tafsir query API.

**Provider registry**: every provider is declared in [lib/shared/core/providers.dart](lib/shared/core/providers.dart). When adding a new feature, this is where you wire the service/notifier into the tree.

**Routing**: named routes via `MaterialApp.onGenerateRoute` in [lib/main.dart:150-222](lib/main.dart#L150-L222). No `go_router` / no declarative router. Route names are constants in [lib/shared/constants/route_paths.dart](lib/shared/constants/route_paths.dart). Arguments are passed as typed param objects (e.g. `SuratPageV3Param`, `HabitGroupDetailViewParam`).

**Theming**: 3 modes — light, dark, brown (traditional Quran paper). Controlled by `themeProvider` → `QPThemeMode` enum. Theme data in [lib/shared/constants/qp_theme_data.dart](lib/shared/constants/qp_theme_data.dart). Color tokens in `QPColors`, text styles in `QPTextStyle` (which read theme from `BuildContext`).

**Native integrations**:
- Android: foreground audio service (`AudioServiceConfig` channel `com.yaumi.qurantafsir.id`), WorkManager callback at `main.dart:94 @pragma('vm:entry-point')`.
- iOS: APNs, Sign in with Apple, deep-link universal links.

---

## 5. Data Flow Walkthrough — Quran Reading

Walk through what happens when a user taps a surah:

1. **Navigation**: User taps a surah in home or bookmark list → `Navigator.pushNamed(RoutePaths.routeSurahPage, arguments: SuratPageV3Param(startPageInIndex: N))`.
2. **Route resolution**: [main.dart:168-173](lib/main.dart#L168-L173) resolves the route, builds `SuratPageV3(param: args)`.
3. **State notifier init**: `SuratPageStateNotifier.initStateNotifier()` runs after first frame. It:
   - Opens `DbLocal` (singleton — no-op if already open).
   - Queries Quran pages for the requested range from SQLite.
   - Loads per-page font assets from `data/quran_fonts/` (bundled, one font per page).
   - Loads translations / tafsirs from SQLite based on user settings.
4. **Render**: `SuratPageV3` builds a `PageView` wrapping the 604 mushaf pages. Each page renders ayahs using the correct custom font. `VisibilityDetector` tracks which page is currently visible and updates reading-progress state.
5. **Bookmark interaction**: User long-presses an ayah → `BookmarksService` writes locally via `SharedPreferenceService` → if logged in, debounced sync to server via `BookmarkApi` (retrofit) → on app resume / next pull, local and server bookmarks are merged.
6. **Audio**: Play button → `AudioRecitationStateNotifier` fetches audio URLs from `AudioApi` → hands them to `AudioRecitationHandler` (our `BaseAudioHandler`) → `just_audio` streams, `audio_service` shows the notification.

---

## 6. Startup Sequence

From [lib/main.dart](lib/main.dart):

```
main()
├── WidgetsFlutterBinding.ensureInitialized()
├── await Firebase.initializeApp(...)
├── SharedPreferenceService().init()         // load cached prefs
├── NotificationService().init()             // local notification channels + TZ
├── Workmanager().initialize(callbackDispatcher)  // background tasks
├── AudioService.init<AudioRecitationHandler>(...)  // Android foreground channel
├── GlobalConfiguration().loadFromAsset('env')  // assets/cfg/env.json
├── FlutterError.onError = Crashlytics...    // crash handlers
├── PlatformDispatcher.instance.onError = Crashlytics...
└── runApp(ProviderScope(overrides: [audioHandler, sharedPrefService, aliceService], child: MyApp))

MyApp.initState:
└── addPostFrameCallback → themeProvider.initStateNotifier()  // load saved theme

MyApp.build:
├── ref.watch(sharedPreferenceServiceProvider)
├── ref.watch(authenticationService)  // hydrate isLoggedIn from token
├── ref.watch(themeProvider)
└── MaterialApp(
      initialRoute = '/' (Splash),
      onGenerateRoute → RoutePaths switch
    )

SplashPage → (login check) → MainPage (5-tab scaffold)
```

These awaits run **sequentially**. See perf roadmap item #9 — there are parallelization wins here.

---

## 7. Performance Improvement Roadmap

Ranked by impact. Each row: issue → file → fix approach → effort.

### Critical / High

| # | Issue | File(s) | Fix | Effort |
|---|---|---|---|---|
| 1 | **604 per-page Quran fonts bundled as assets** — inflates install size significantly | [pubspec.yaml:114](pubspec.yaml#L114) (`data/quran_fonts/`) | **Must stay offline-capable** (core selling point). Do NOT move to a CDN on first run. Safe options that preserve offline-first: (a) **font subsetting** — strip unused glyphs per page file with `pyftsubset` / `fonttools`, often 40-70% smaller; (b) **deduplicate** — many pages likely share glyph sets, merge into fewer fonts; (c) **Play Asset Delivery (Android) / On-Demand Resources (iOS)** — ships via store at install time, still works offline afterward, but reduces initial install download; (d) lazily load font bytes into memory only when the page is near-visible (keeps them on disk but off heap). | Large |
| 2 | **`PageView` materializes page children eagerly** | [lib/pages/surat_page_v3/surat_page_v3.dart:760](lib/pages/surat_page_v3/surat_page_v3.dart#L760) (`_buildPagesInFullPage`) and [:786](lib/pages/surat_page_v3/surat_page_v3.dart#L786), [:827](lib/pages/surat_page_v3/surat_page_v3.dart#L827) | Convert `PageView(children: [...604])` → `PageView.builder(itemCount: 604, itemBuilder: ...)`. Dart builds only visible + adjacent pages. | Medium |
| 3 | **Nested `ListView.builder` inside a scrolling parent** | [lib/pages/home_page_v2/home_page_v2.dart:478](lib/pages/home_page_v2/home_page_v2.dart#L478), [:528](lib/pages/home_page_v2/home_page_v2.dart#L528) | Replace outer `ListView` + inner `ListView.builder` with `CustomScrollView` + multiple `SliverList`s, or hoist inner lists to `shrinkWrap: false` inside a fixed-height container. Current structure forces unbounded height measurement. | Medium |
| 4 | **Synchronous SQLite operations on main isolate** | [lib/shared/core/database/db_local.dart](lib/shared/core/database/db_local.dart) | Move heavy query + JSON parsing into `compute()` (isolate) — especially page-bulk loads and tafsir text. Smaller queries can stay on-thread. | Medium |

### Medium

| # | Issue | File(s) | Fix | Effort |
|---|---|---|---|---|
| 5 | **Watches the whole state when only one field is needed** | [lib/pages/home_page_v2/home_page_v2.dart:274](lib/pages/home_page_v2/home_page_v2.dart#L274) (`ref.watch(authenticationService).isLoggedIn` — rebuilds on any auth change). Audit all `ref.watch(...)` sites. | Use `ref.watch(provider.select((s) => s.oneField))` to narrow rebuild scope. | Small per site |
| 6 | **Three stacked `ValueListenableBuilder`s in the AppBar title** | [lib/pages/surat_page_v3/surat_page_v3.dart:208-241](lib/pages/surat_page_v3/surat_page_v3.dart#L208-L241) | Combine the listenables with `Listenable.merge([...])` + a single builder. | Small |
| 7 | **Providers without `.autoDispose`** hold state forever even when their page is off-stack | [lib/shared/core/providers.dart](lib/shared/core/providers.dart) | Audit each provider. Keep singletons (sharedPrefs, dio, auth, theme, audio). Switch page-scoped notifiers to `StateNotifierProvider.autoDispose`. | Medium |
| 8 | **`setState(() {})` just to force rebuild after login** | [lib/pages/surat_page_v3/surat_page_v3.dart:497](lib/pages/surat_page_v3/surat_page_v3.dart#L497) | Drive the refresh through a provider: `ref.invalidate(suratPageProvider)` or re-read via a listen callback on `authenticationService`. | Small |
| 9 | **Sequential awaits in `main()`** | [lib/main.dart:40-57](lib/main.dart#L40-L57) | Parallelize independent inits with `Future.wait([Firebase.initializeApp(...), sharedPreferenceService.init(), NotificationService().init()])`. Keep `AudioService.init` after `GlobalConfiguration` if it depends on env. | Small |
| 10 | **Monolithic `_buildAyah` (~285 lines)** | [lib/pages/surat_page_v3/surat_page_v3.dart:883](lib/pages/surat_page_v3/surat_page_v3.dart#L883) onward | Extract to smaller `const`-constructible widgets (AyahNumber, AyahArabic, AyahTranslation, AyahActions). `const` widgets skip rebuilds. | Medium |
| 11 | **Repeated `Image.asset` of the same `bismillah_v2.png` without cache hints** | [lib/pages/surat_page_v3/surat_page_v3.dart:1195](lib/pages/surat_page_v3/surat_page_v3.dart#L1195), [:1202](lib/pages/surat_page_v3/surat_page_v3.dart#L1202) | Add `cacheWidth`/`cacheHeight` matching rendered size; precache once at startup via `precacheImage(AssetImage('images/bismillah_v2.png'), context)` in first-frame callback. | Small |
| 12 | **No pagination on Tadabbur / Bookmark lists** | [lib/pages/bookmark_v2/](lib/pages/bookmark_v2/), [lib/pages/tadabbur_surah_list_page/](lib/pages/tadabbur_surah_list_page/) | Add cursor-based pagination in state notifier; trigger next-page fetch on list scroll threshold. Matters if bookmark count grows. | Medium |

### Low

| # | Issue | File(s) | Fix | Effort |
|---|---|---|---|---|
| 13 | **`VisibilityDetectorController.updateInterval` set per-page** (if applicable) | Wherever it's set — grep for `VisibilityDetectorController` | Set once globally at `main()`. | Tiny |
| 14 | **`QPColors.getColorBasedTheme` called inside ayah render loop** | [lib/pages/surat_page_v3/surat_page_v3.dart](lib/pages/surat_page_v3/surat_page_v3.dart) `_buildAyah` | Resolve theme colors once in the page-level `build()` and pass them down, or memoize via a context-extension. | Small |

---

## 8. Quick Reference — File Index

The 15 files a returning developer should know:

| File | What it does |
|---|---|
| [lib/main.dart](lib/main.dart) | Entry point, startup sequence, route table. |
| [lib/shared/core/providers.dart](lib/shared/core/providers.dart) | Single registry of every Riverpod provider. Start here when wiring a new feature. |
| [lib/shared/core/services/dio_service.dart](lib/shared/core/services/dio_service.dart) | HTTP client (3 variants). All network traffic goes through here. |
| [lib/shared/core/database/db_local.dart](lib/shared/core/database/db_local.dart) | SQLite singleton for Quran content. |
| [lib/shared/core/services/shared_preference_service.dart](lib/shared/core/services/shared_preference_service.dart) | Typed wrapper over `SharedPreferences` — auth token, theme, onboarding flags. |
| [lib/shared/core/services/authentication_service.dart](lib/shared/core/services/authentication_service.dart) | Auth flow + `isLoggedIn` state. |
| [lib/shared/core/state_notifiers/base_state_notifier.dart](lib/shared/core/state_notifiers/base_state_notifier.dart) | Base class for page/feature notifiers. |
| [lib/shared/ui/state_notifier_connector.dart](lib/shared/ui/state_notifier_connector.dart) | The page-boilerplate pattern (provider + init + rebuild). |
| [lib/shared/constants/route_paths.dart](lib/shared/constants/route_paths.dart) | All route names as constants. |
| [lib/shared/constants/qp_theme_data.dart](lib/shared/constants/qp_theme_data.dart) | Light / dark / brown theme defs. |
| [lib/pages/main_page/main_page.dart](lib/pages/main_page/main_page.dart) | 5-tab bottom-nav scaffold. |
| [lib/pages/splash_page/splash_page.dart](lib/pages/splash_page/splash_page.dart) | Boot → login check → main. |
| [lib/pages/surat_page_v3/surat_page_v3.dart](lib/pages/surat_page_v3/surat_page_v3.dart) | The mushaf reader — biggest file, biggest perf target. |
| [lib/pages/home_page_v2/home_page_v2.dart](lib/pages/home_page_v2/home_page_v2.dart) | Home dashboard — nested list perf hotspot. |
| [pubspec.yaml](pubspec.yaml) | Dependency list + asset bundle (incl. the 604 page fonts). |
| [analysis_options.yaml](analysis_options.yaml) | Lint rules. |

---

## 9. What Changed Since You Left

If your last commit here was ~2 years ago, the repo has recently been migrated to **Flutter 3.41.7 / Dart 3.11**. Deprecated API migrations already applied:

- `Color.withOpacity(x)` → `Color.withValues(alpha: x)`
- `WillPopScope` → `PopScope` with `canPop: false` + `onPopInvokedWithResult`
- `Radio(groupValue:, onChanged:)` → `RadioGroup<T>` ancestor wrapping `Radio(value:)`
- `StateNotifierProviderRef<N, S>` / `ProviderRef<T>` → unified `Ref` (Riverpod 2.5+)
- `androidAllowWhileIdle: true` → `androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle`
- `dialogBackgroundColor` → `dialogTheme.backgroundColor`
- `print(...)` → `debugPrint(...)` (tree-shaken in release)
- `use_build_context_synchronously` lint cleaned — `mounted` for State.context, `context.mounted` for BuildContext params
- `alice` HTTP inspector restored and wired as `aliceServiceProvider` override in `main.dart`

Analyzer is clean (0 issues). For the full commit history see `git log --oneline master`.

---

## Appendix — Running the app

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # retrofit + json_serializable codegen
flutter run                                                 # debug
flutter build apk --release                                 # Android release
flutter build ios --release                                 # iOS release (requires signing)
```

Env config is read from `assets/cfg/env.json` at startup via `GlobalConfiguration`.
