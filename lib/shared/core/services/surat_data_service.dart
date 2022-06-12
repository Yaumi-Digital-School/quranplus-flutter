class SuratDataService {
  SuratDataService();

  List<List<String>>? _translations;
  List<List<String>>? _tafsirs;
  List<List<String>>? _latins;

  void setTranslations(List<List<String>> value) {
    _translations = value;
  }

  void setTafsirs(List<List<String>> value) {
    _tafsirs = value;
  }

  void setLatins(List<List<String>> value) {
    _latins = value;
  }

  List<List<String>> get translations => _translations ?? [];
  List<List<String>> get tafsirs => _tafsirs ?? [];
  List<List<String>> get latins => _latins ?? [];
}
