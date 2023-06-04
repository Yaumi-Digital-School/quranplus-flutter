import 'package:connectivity_plus/connectivity_plus.dart';

extension InternetConnection on ConnectivityResult {
  bool get isOnInternetConnection =>
      this == ConnectivityResult.wifi || this == ConnectivityResult.mobile;
}
