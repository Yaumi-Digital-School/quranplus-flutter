import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_view.dart';
import 'package:qurantafsir_flutter/shared/core/services/main_page_provider.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/apis/habit_group_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart'
    as custom_date_utils;

class DeepLinkService {
  DeepLinkService({
    required this.habitGroupApi,
    required this.authenticationService,
    required this.sharedPreferenceService,
    required this.mainPageProvider,
  });

  final HabitGroupApi habitGroupApi;
  final AuthenticationService authenticationService;
  final SharedPreferenceService sharedPreferenceService;
  final MainPageProvider mainPageProvider;

  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    final initLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initLink != null) {
      await _handleDeepLink(initLink.link);
    }
    FirebaseDynamicLinks.instance.onLink.listen(
      (event) async {
        await _handleDeepLink(event.link);
      },
    );
  }

  Future<void> _handleDeepLink(Uri link) async {
    if (link.path.contains("RtQw") &&
        (link.queryParameters["id"] ?? '').isNotEmpty) {
      await _handleJoinGroup(
        int.parse(link.queryParameters["id"]!),
      );

      return;
    }

    mainPageProvider.setShouldInvalidLinkBottomSheet(true);
    _navigatorKey!.currentState!.pushReplacementNamed(
      RoutePaths.routeMain,
    );
  }

  Future<void> _handleJoinGroup(
    int id,
  ) async {
    if (!authenticationService.isLoggedIn) {
      await sharedPreferenceService.setForceLoginParam(
        ForceLoginParam(
          nextPath: RoutePaths.routeHabitGroupDetail,
          arguments: <String, dynamic>{
            'id': id,
          },
        ),
      );

      mainPageProvider.setShouldShowSignInBottomSheet(true);

      _navigatorKey!.currentState!.pushReplacementNamed(
        RoutePaths.routeMain,
      );

      return;
    }

    try {
      final response = await habitGroupApi.joinGroup(
        groupId: id,
        request: JoinHabitGroupRequest(
          date: custom_date_utils.DateCustomUtils.getCurrentDateInString(),
        ),
      );

      if (response.response.statusCode == 400) {
        mainPageProvider.setShouldInvalidGroupBottomSheet(true);
        _navigatorKey!.currentState!.pushReplacementNamed(
          RoutePaths.routeMain,
        );

        return;
      }

      _navigatorKey!.currentState!.pushReplacementNamed(
        RoutePaths.routeHabitGroupDetail,
        arguments: HabitGroupDetailViewParam(
          id: id,
          isSuccessJoinGroup: response.data,
        ),
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _handleJoinGroup() method',
      );
      rethrow;
    }
  }
}
