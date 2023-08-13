import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class InternetUtils {
  static Future<bool> isInternetAvailable() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final response = await http.get(Uri.parse('https://www.google.com'));

        return response.statusCode == 200;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
