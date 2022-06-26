import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/surat_data_service.dart';

final Provider<SuratDataService> suratDataServiceProvider =
    Provider<SuratDataService>((_) {
  return SuratDataService();
});
