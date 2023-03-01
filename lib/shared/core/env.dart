import 'package:global_configuration/global_configuration.dart';

class EnvConstants {
  static final GlobalConfiguration _config = GlobalConfiguration();
  static const String _baseUrl = 'baseUrl';
  static const String _apiToken = 'apiToken';

  static String? get baseUrl {
    return _config.getValue(_baseUrl);
  }

  static String? get apiToken {
    return _config.getValue(_apiToken);
  }
}
