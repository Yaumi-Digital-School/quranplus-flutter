class SuratDataService {
  SuratDataService();

  List<List<String>>? _translations;
  List<List<String>>? _tafsirs;

  void setTranslations(List<List<String>> value) {
    _translations = value;
  }

  void setTafsirs(List<List<String>> value) {
    _tafsirs = value;
  }

  List<List<String>> get translations => _translations ?? [];
  List<List<String>> get tafsirs => _tafsirs ?? [];
}
