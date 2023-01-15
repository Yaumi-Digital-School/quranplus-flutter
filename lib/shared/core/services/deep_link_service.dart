import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_view.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/apis/habit_group_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart'
    as custom_date_utils;

class DeepLinkService {
  final HabitGroupApi habitGroupApi;
  DeepLinkService({required this.habitGroupApi});

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    final initLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initLink != null) {
      _handleDeepLink(initLink.link, navigatorKey);
    }
    FirebaseDynamicLinks.instance.onLink.listen((event) {
      _handleDeepLink(event.link, navigatorKey);
    });
  }

  void _handleDeepLink(Uri link, GlobalKey<NavigatorState> navigatorKey) async {
    try {
      if (link.path.contains("RtQw") &&
          link.queryParameters["id"] != null &&
          link.queryParameters["id"] != "") {
        await _handleJoinGroup(
          int.parse(link.queryParameters["id"]!),
          navigatorKey,
        );
      }
    } catch (e) {
      print("group not found");
    }
  }

  Future<void> _handleJoinGroup(
    int id,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    try {
      final response = await habitGroupApi.joinGroup(
        groupId: id,
        request: JoinHabitGroupRequest(
          date: custom_date_utils.DateUtils.getCurrentDateInString(),
        ),
      );

      if (response.data) {
        navigatorKey.currentState!.pushReplacementNamed(
          RoutePaths.routeHabitGroupDetail,
          arguments: HabitGroupDetailViewParam(
            groupName: "",
            id: id,
          ),
        );
      } else if (!response.data) {
        navigatorKey.currentState!.pushReplacementNamed(
          RoutePaths.routeHabitGroupDetail,
          arguments: HabitGroupDetailViewParam(
            groupName: "",
            id: id,
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
