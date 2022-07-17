import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';

final Provider<DioService> dioServiceProvider = Provider<DioService>((_) {
  return DioService(
    baseUrl: AppConstants.baseUrl,
  );
});

final Provider<SharedPreferenceService> sharedPreferenceServiceProvider =
    Provider<SharedPreferenceService>((ref) {
  final SharedPreferenceService service = SharedPreferenceService();
  return service;
});
