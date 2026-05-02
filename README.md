# Quran Tafsir App

## Technical Docs
- [Docs Link](https://docs.google.com/document/d/13dj3vLI09XOuCy3Deh2nCiAieruJzf2mBGGSgAmGH6g/edit?usp=sharing)

## Development Environment

- Flutter Version : 2.10.2

Untuk mempermudah versioning, bisa gunakan https://pub.dev/packages/fvm di local masing-masing

## Instalasi Repository

Berikut ini adalah cara menggunakan repository ini di local masing-masing : 

1. Install Flutter & Dart, bisa menggunakan https://pub.dev/packages/fvm. Letak perbedaannya nanti adalah pada pemanggilan command flutter, apabila menggunakan fvm maka pemanggilannya adalah 
```
fvm flutter ...
``` 
dan apabila tanpa fvm adalah 
```
flutter ...
```
2. Clone Repository
3. Download dependencies dengan `fvm flutter pub get`
4. Untuk melakukan generate beberapa file yang menggunakan library retrofit, jalankan 
```
fvm flutter pub run build_runner build --delete-conflicting-outputs
```
5. Untuk iOS, jalankan `pod install` di dalam folder `ios`
6. Jalankan aplikasi di emulator/hp anda dengan command `fvm flutter run`

## Setup Environment Variable

1. Tambahkan file `env.json` di dalam directory `assets/cfg`
2. Isi file `env.json` sesuai kebutuhan, silakan minta pada developer lain untuk value-value terupdatenya

## State Management (Riverpod)

Project ini menggunakan **Riverpod 4** dengan `riverpod_annotation` untuk code generation. Provider didefinisikan dengan anotasi `@riverpod`, lalu boilerplate-nya digenerate oleh `build_runner` ke file `.g.dart`.

Stack:
- `flutter_riverpod: ^3.0.0`
- `riverpod_annotation: ^4.0.0`
- `riverpod_generator: ^4.0.0` (dev)

### Cara Menambahkan Provider Baru

1. Buat file notifier di lokasi yang sesuai (mis. `lib/pages/<page>/notifiers/xxx_notifier.dart` untuk state per-halaman, atau `lib/shared/core/providers.dart` untuk yang global).
2. Tambahkan `part 'xxx_notifier.g.dart';` di atas file.
3. Anotasi class:
   - `@riverpod` → auto-dispose (default), provider hilang ketika tidak ada listener.
   - `@Riverpod(keepAlive: true)` → tetap hidup sampai app exit.
4. Extend `_$ClassName` dan implement `build()` sebagai initial state.
5. Generate file `.g.dart`:
   ```
   fvm flutter pub run build_runner build --delete-conflicting-outputs
   ```
   Selama development, jalankan `... build_runner watch ...` supaya auto-regenerate setiap save.

### Cara Mengedit Provider

- Setelah mengubah signature `build()`, menambah/menghapus class beranotasi, atau mengganti `keepAlive`, **wajib rerun build_runner** supaya `.g.dart` ter-regenerate.
- Kalau ada konflik file generated, gunakan flag `--delete-conflicting-outputs`.
- **Jangan edit `.g.dart` manual** — file tersebut akan di-overwrite saat generate.

### Contoh Use Case

#### A. Simple value provider

Untuk state primitif (string, int, bool) yang punya setter sederhana:

```dart
// lib/shared/core/providers.dart
@Riverpod(keepAlive: true)
class CalculationMethod extends _$CalculationMethod {
  @override
  String build() => 'singapore';
  void set(String value) => state = value;
}
```

Pemakaian di widget:
```dart
final method = ref.watch(calculationMethodProvider);
ref.read(calculationMethodProvider.notifier).set('makkah');
```

#### B. Class-based notifier dengan custom state

Untuk halaman dengan banyak field state, pisahkan state ke class sendiri (dengan `copyWith`) dan notifier-nya:

```dart
// states/home_page_state.dart
class HomePageState {
  HomePageState({this.name = '', this.juzElements});
  final String name;
  final List<JuzElement>? juzElements;

  HomePageState copyWith({String? name, List<JuzElement>? juzElements}) =>
      HomePageState(
        name: name ?? this.name,
        juzElements: juzElements ?? this.juzElements,
      );
}
```

```dart
// notifiers/home_page_notifier.dart
@riverpod
class HomePageNotifier extends _$HomePageNotifier {
  @override
  HomePageState build() {
    Future.microtask(_init);          // async init pattern
    return HomePageState();           // initial sync state
  }

  Future<void> _init() async {
    final json = await rootBundle.loadString(AppConstants.jsonJuz);
    state = state.copyWith(juzElements: juzFromJson(json).juz);
  }
}
```

#### C. Optimasi rebuild dengan `.select()`

Default `ref.watch(provider)` akan rebuild widget setiap kali state apapun berubah. Pakai `.select()` untuk subscribe ke field tertentu saja:

```dart
// rebuild HANYA ketika `name` berubah
final name = ref.watch(homePageProvider.select((s) => s.name));
```

Untuk list panjang, kembalikan boolean (bukan reference) supaya hanya item yang relevan yang rebuild:

```dart
// HomeSurahItem — hanya item yang audio-nya sedang loading yang rebuild,
// bukan semua 114+ surah
final isAudioLoading = ref.watch(
  homePageProvider.select((s) => s.audioSuratLoaded == surat),
);
```

#### D. Auto-dispose vs `keepAlive`

```dart
@riverpod                       // auto-dispose: state hilang ketika tidak ada listener
class SearchQueryNotifier extends _$SearchQueryNotifier { ... }

@Riverpod(keepAlive: true)      // tetap hidup sampai app exit
class DioServiceNotifier extends _$DioServiceNotifier { ... }
```

Pakai **`keepAlive: true`** untuk: services (Dio, DB), config global (theme, calculation method, madhab), data yang dipakai banyak halaman.

Pakai **default (auto-dispose)** untuk: state per-halaman, query input, form state, data sementara — supaya memory dibebaskan ketika halaman ditutup.

#### E. Mengakses provider lain dari dalam notifier

Gunakan `ref.read` (bukan `watch`) di dalam method notifier:

```dart
@riverpod
class SuratPageNavigationNotifier extends _$SuratPageNavigationNotifier {
  void initNavigation() {
    // baca STATE dari provider lain
    final pages = ref.read(suratPageContentProvider).pages!;

    // panggil METHOD di notifier lain
    ref
        .read(suratPageBookmarkProvider.notifier)
        .checkIsBookmarkExists(_startPageInIndex + 1);
  }
}
```

### Struktur Folder yang Direkomendasikan

Untuk halaman dengan state kompleks, ikuti pattern dari `lib/pages/surat_page_v3/`:

```
lib/pages/<page>/
├── <page>.dart              # widget utama (thin, side-effects only)
├── notifiers/               # @riverpod classes
│   ├── xxx_notifier.dart
│   └── xxx_notifier.g.dart  # generated — JANGAN diedit manual
├── states/                  # state class dengan copyWith
│   └── xxx_state.dart
└── widgets/                 # ConsumerWidget per section, pakai .select()
    └── xxx_widget.dart
```

Pisahkan satu notifier per **domain concern** (mis. `content`, `navigation`, `bookmark`, `habit`) supaya tiap notifier kecil dan mudah ditest.

## Cara Berkontribusi pada Repository

Branch `master` adalah branch utama yang digunakan. Aplikasi yang sudah di publish ke publik adalah aplikasi yang di build dari branch `master`.
Berikut ini adalah cara berkontribusi pada Repository ini : 

1. Lakukan pull dari latest master untuk mendapatkan perubahan terbaru dari Repository
2. Buatlah branch baru dari branch `master` dengan nama branch yang melambangkan fitur yang dibuat. Konvensi yang digunakan adalah [Conventional Commit](https://www.conventionalcommits.org/en/v1.0.0/#summary)
3. Lakukan development di local di branch baru tersebut, lalu push perubahan ke branch baru tersebut
4. Setelah development selesai, buatlah Pull Request (PR).
**notes:** Pada pembuatan MR, buatlah title MR yang deskriptif dengan format berikut ini berdasarkan standar [Conventional Commit](https://www.conventionalcommits.org/en/v1.0.0/#summary):
- Prefix `feat:` untuk pembuatan fitur baru, contoh : 
```
feat: add change font size feature in surat page v3
```
- Prefix `refactor:` untuk perubahan kode yang tidak menghasilkan fitur baru. Misalnya adalah memecah function menjadi beberapa function kecil, contoh : 
```
refactor: code tidying to increase readability
```
- Prefix `fix:` untuk perubahan code yang bertujuan untuk membereskan bug, contoh : 
```
fix: set default value on nullable variable to avoid null safety error
```
5. Selesai
