# Quran Tafsir App

## Development Environment

- Flutter Version : 2.10.2
- Dart Version : 2.16.2

Untuk mempermudah versioning, bisa gunakan https://pub.dev/packages/fvm di local masing-masing

## Instalasi Repository

Berikut ini adalah cara menggunakan repository ini di local masing-masing : 

1. Install Flutter & Dart, bisa menggunakan https://pub.dev/packages/fvm. Letak perbedaannya nanti adalah pada pemanggilan command flutter, apabila menggunakan fvm maka pemanggilannya adalah `fvm flutter ...` dan apabila tanpa fvm adalah `flutter ...`
2. Clone Repository
3. Download dependencies dengan `fvm flutter pub get`
4. Untuk melakukan generate beberapa file yang menggunakan library retrofit, jalankan `fvm flutter pub run build_runner build --delete-conflicting-outputs`
5. Untuk iOS, jalankan `pod install` di dalam folder `ios`
6. Jalankan aplikasi di emulator/hp anda dengan command `fvm flutter run`
