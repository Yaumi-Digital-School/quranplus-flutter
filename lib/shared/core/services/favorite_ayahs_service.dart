import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';

class FavoriteAyahsService {
  bool _isMerged = false;
  final DbLocal _db = DbLocal();

  bool get isMerged => _isMerged;
  void setIsMerged(bool value) => _isMerged = value;

  Future<List<FavoriteAyahs>> getFavoriteAyahListLocal() async {
    final List<FavoriteAyahs> result = await _db.getAllFavoriteAyahs();
    return result;
  }

  Future<int> saveFavoriteAyahs(FavoriteAyahs favoriteAyahs) async {
    return await _db.saveFavoriteAyahs(favoriteAyahs);
  }

  Future<int> deleteFavoriteAyahs(int ayahID) async {
    return await _db.deleteFavoriteAyahs(ayahID) ?? 0;
  }
}
