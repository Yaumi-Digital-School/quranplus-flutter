import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_view.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/home_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/error_bottom_sheet_content.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/home_header_section.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/home_search_button.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/home_surah_list.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart' as date_util;
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/sign_in_bottom_sheet.dart';
import 'package:retrofit/retrofit.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';

class HomePageV2 extends ConsumerStatefulWidget {
  const HomePageV2({super.key});

  @override
  ConsumerState<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends ConsumerState<HomePageV2> {
  @override
  Widget build(BuildContext context) {
    final mainPage = ref.read(mainPageProvider);

    if (mainPage.getShouldShowSignInBottomSheetAndReset()) {
      _showSignInBottomSheet();
    }
    if (mainPage.getShouldSShowInvalidGroup()) {
      _showInvalidGroupBottomSheet();
    }
    if (mainPage.getShouldSShowInvalidLink()) {
      _showInvalidLinkBottomSheet();
    }

    return Scaffold(
      backgroundColor: QPColors.getColorBasedTheme(
        dark: QPColors.darkModeMassive,
        light: QPColors.brandFair,
        brown: QPColors.brownModeRoot,
        context: context,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              children: const [
                HomeHeaderSection(),
                HomeSurahList(),
              ],
            ),
            const Positioned(
              bottom: kHomeSearchButtonDiameter * 2 / 6,
              right: kHomeSearchButtonDiameter * 2 / 6,
              child: HomeSearchButton(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignInBottomSheet() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      SignInBottomSheet.show(
        context: context,
        onClose: () {
          ref.read(homePageProvider.notifier).getAndRemoveForceLoginParam();
        },
        onTapSignInWithGoogle: () async => _signIn(type: SignInType.google),
        onTapSignInWithApple: () async => _signIn(type: SignInType.apple),
      );
    });
  }

  Future<void> _signIn({required SignInType type}) async {
    final SignInResult result = await ref
        .read(authenticationService)
        .signIn(type: type);

    if (result == SignInResult.failedAccountDeleted) {
      if (!mounted) return;
      Navigator.pop(context);
      await Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        SignInBottomSheet.showAccountDeletedInfo(context: context);
      });

      return;
    }
    ref.invalidate(dioServiceProvider);
    await ref.read(habitDailySummaryService).syncHabit();
    ref.read(bookmarksService).clearBookmarkAndMergeFromServer();

    ForceLoginParam? param = await ref
        .read(homePageProvider.notifier)
        .getAndRemoveForceLoginParam();

    final HttpResponse<dynamic> req = await ref
        .read(habitGroupApiProvider)
        .joinGroup(
          groupId: param?.arguments?['id'] ?? 0,
          request: JoinHabitGroupRequest(
            date: date_util.DateCustomUtils.getCurrentDateInString(),
          ),
        );

    final bool shouldRedirect =
        result == SignInResult.success &&
        req.response.statusCode == 200 &&
        param != null;

    if (!mounted) return;
    Navigator.pop(context);

    if (shouldRedirect) {
      Object? args;
      switch (param.nextPath) {
        case RoutePaths.routeHabitGroupDetail:
          args = HabitGroupDetailViewParam(
            id: param.arguments?['id'],
            isSuccessJoinGroup: req.data,
          );
      }

      if (!mounted) return;
      Navigator.pushNamed(context, param.nextPath ?? '', arguments: args);
    }

    if (req.response.statusCode == 400) {
      ref.read(mainPageProvider).setShouldInvalidGroupBottomSheet(true);
    }

    setState(() {});
  }

  void _showInvalidLinkBottomSheet() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      GeneralBottomSheet.showBaseBottomSheet(
        context: context,
        widgetChild: const ErrorBottomSheetContent(
          title: "Link not found",
          description: "Make sure the link you entered is valid",
        ),
      );
    });
  }

  void _showInvalidGroupBottomSheet() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      GeneralBottomSheet.showBaseBottomSheet(
        context: context,
        widgetChild: const ErrorBottomSheetContent(
          title: "Group link not found",
          description:
              "The group may have been deleted by the admin, try contacting the group admin",
        ),
      );
    });
  }
}
