# Quran Tafsir App

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

## Cara Berkontribusi pada Repository

Branch `master` adalah branch utama yang digunakan. Aplikasi yang sudah di publish ke publik adalah aplikasi yang di build dari branch `master`.
Berikut ini adalah cara berkontribusi pada Repository ini : 

1. Lakukan pull dari latest master untuk mendapatkan perubahan terbaru dari Repository
2. Buatlah branch baru dari branch `master` dengan nama branch yang melambangkan fitur yang dibuat
3. Lakukan development di local di branch baru tersebut, lalu push perubahan ke branch baru tersebut
4. Setelah development selesai, buatlah Merge Request (MR) di gitlab anda untuk di merge ke master
**notes:** Pada pembuatan MR, buatlah title MR yang deskriptif dengan format berikut ini :
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
5. Setelah MR sudah dibuat, beritahukan di grup bahwa MR sudah dibuat agar bisa di review terlebih dahulu :D
