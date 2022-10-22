import 'package:qurantafsir_flutter/shared/core/apis/favorite_ayah_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';
import 'package:retrofit/retrofit.dart';

class FavoriteAyahsService {
  FavoriteAyahsService({
    required FavoriteAyahApi favoriteAyahApi,
  }) : _favoriteAyahApi = favoriteAyahApi;

  final FavoriteAyahApi _favoriteAyahApi;

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

  Future<void> toggleAyahToServer({
    required FavoriteAyahs ayah,
  }) async {
    try {
      HttpResponse<ToggleFavoriteAyahResponse> _ =
          await _favoriteAyahApi.toggleFavoriteAyah(
        request: ayah,
      );
    } catch (e) {
      // TODO(yumnanaruto): add logging here
    }
  }

  Future<List<FavoriteAyahs>> _getFavoriteAyahListFromServer() async {
    List<FavoriteAyahs> result = <FavoriteAyahs>[];
    final HttpResponse<List<GetFavoriteAyahListItemResponse>> response =
        await _favoriteAyahApi.getFavoriteAyahs();

    if (response.response.statusCode == 200 && response.data.isNotEmpty) {
      for (GetFavoriteAyahListItemResponse item in response.data) {
        result.add(FavoriteAyahs.fromGetListResponseItemResponse(item));
      }
    }

    return result;
  }

  Future<void> clearFavoriteAndMergeFromServer() async {
    await _db.clearTableFavoriteAyahs();
    final List<FavoriteAyahs> _serverFavoriteAyahs =
        await _getFavoriteAyahListFromServer();
    await _db.bulkCreateFavoriteAyahs(_serverFavoriteAyahs);
    setIsMerged(true);
  }

  Future<void> mergeFavoriteAyahToServer() async {
    if (_isMerged) {
      return;
    }

    final List<FavoriteAyahs> _localFavoriteAyahs =
        await getFavoriteAyahListLocal();
    if (_localFavoriteAyahs.isEmpty) {
      final List<FavoriteAyahs> _serverFavoriteAyahs =
          await _getFavoriteAyahListFromServer();
      await _db.bulkCreateFavoriteAyahs(_serverFavoriteAyahs);
      setIsMerged(true);
      return;
    }

    final List<FavoriteAyahs> request = <FavoriteAyahs>[];
    for (FavoriteAyahs ayah in _localFavoriteAyahs) {
      request.add(ayah);
    }

    final HttpResponse<MergeFavoriteAyahResponse> _ =
        await _favoriteAyahApi.mergeFavoriteAyahs(
      request: request,
    );

    final List<FavoriteAyahs> _serverFavoriteAyahs =
        await _getFavoriteAyahListFromServer();
    await _db.clearTableFavoriteAyahs();
    await _db.bulkCreateFavoriteAyahs(_serverFavoriteAyahs);
    setIsMerged(true);
  }
}
