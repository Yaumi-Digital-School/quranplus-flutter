import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_view.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/card_start_habit.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/daily_progress_tracker_detail_card/daily_progress_tracker_detail_card.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/pages/read_tadabbur/read_tadabbur_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';

import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/models/juz.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart' as date_util;
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/alert_dialog.dart';
import 'package:qurantafsir_flutter/widgets/daily_progress_tracker.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/sign_in_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:retrofit/retrofit.dart';
import 'home_page_state_notifier.dart';
import 'widgets/adzan_card/adzan_card_widget.dart';

class HomePageV2 extends StatefulWidget {
  const HomePageV2({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomePageV2> {
  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HomePageStateNotifier, HomePageState>(
      key: GlobalKey(),
      stateNotifierProvider:
          StateNotifierProvider<HomePageStateNotifier, HomePageState>(
        (ref) {
          return HomePageStateNotifier(
            sharedPreferenceService: ref.read(sharedPreferenceServiceProvider),
            habitDailySummaryService: ref.read(habitDailySummaryService),
            authenticationService: ref.read(authenticationService),
            mainPageProvider: ref.read(mainPageProvider),
            audioRecitationStateNotifier:
                ref.read(audioRecitationProvider.notifier),
          );
        },
      ),
      onStateNotifierReady: (notifier, ref) async {
        await notifier.initStateNotifier();
      },
      builder: (
        BuildContext context,
        HomePageState state,
        HomePageStateNotifier notifier,
        WidgetRef ref,
      ) {
        if (notifier.mainPageProvider
            .getShouldShowSignInBottomSheetAndReset()) {
          _showSignInBottomSheet(notifier, ref);
        }

        if (notifier.mainPageProvider.getShouldSShowInvalidGroup()) {
          _showInvalidGroupBottomSheet();
        }

        if (notifier.mainPageProvider.getShouldSShowInvalidLink()) {
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
            child: ListSuratByJuz(
              notifier: notifier,
              parentState: state,
            ),
          ),
        );
      },
    );
  }

  void _showSignInBottomSheet(
    HomePageStateNotifier notifier,
    WidgetRef ref,
  ) {
    Future.delayed(Duration.zero, () {
      SignInBottomSheet.show(
        context: context,
        onClose: () {
          notifier.getAndRemoveForceLoginParam();
        },
        onTapSignInWithGoogle: () async => _signIn(
          notifier: notifier,
          ref: ref,
          type: SignInType.google,
        ),
        onTapSignInWithApple: () async => _signIn(
          notifier: notifier,
          ref: ref,
          type: SignInType.apple,
        ),
      );
    });
  }

  Future<void> _signIn({
    required WidgetRef ref,
    required HomePageStateNotifier notifier,
    required SignInType type,
  }) async {
    final SignInResult result = await ref.read(authenticationService).signIn(
          type: type,
        );

    if (result == SignInResult.failedAccountDeleted && context.mounted) {
      Navigator.pop(context);
      await Future.delayed(const Duration(seconds: 1), () {
        SignInBottomSheet.showAccountDeletedInfo(context: context);
      });

      return;
    }
    await ref.read(habitDailySummaryService).syncHabit();
    ref.read(bookmarksService).clearBookmarkAndMergeFromServer();

    ForceLoginParam? param = await notifier.getAndRemoveForceLoginParam();

    final HttpResponse<dynamic> req =
        await ref.read(habitGroupApiProvider).joinGroup(
              groupId: param?.arguments?['id'] ?? 0,
              request: JoinHabitGroupRequest(
                date: date_util.DateCustomUtils.getCurrentDateInString(),
              ),
            );

    final bool shouldRedirect = result == SignInResult.success &&
        req.response.statusCode == 200 &&
        param != null;

    if (context.mounted) {
      Navigator.pop(context);
    }

    if (shouldRedirect) {
      Object? args;
      switch (param.nextPath) {
        case RoutePaths.routeHabitGroupDetail:
          args = HabitGroupDetailViewParam(
            id: param.arguments?['id'],
            isSuccessJoinGroup: req.data,
          );
      }

      if (context.mounted) {
        Navigator.pushNamed(
          context,
          param.nextPath ?? '',
          arguments: args,
        );
      }
    }

    if (req.response.statusCode == 400) {
      notifier.mainPageProvider.setShouldInvalidGroupBottomSheet(true);
    }

    setState(() {});
  }

  void _showInvalidLinkBottomSheet() {
    Future.delayed(Duration.zero, () {
      GeneralBottomSheet.showBaseBottomSheet(
        context: context,
        widgetChild: _getErrorWidget(
          "Link not found",
          "Make sure the link you entered is valid",
        ),
      );
    });
  }

  void _showInvalidGroupBottomSheet() {
    Future.delayed(Duration.zero, () {
      GeneralBottomSheet.showBaseBottomSheet(
        context: context,
        widgetChild: _getErrorWidget(
          "Group link not found",
          "The group may have been deleted by the admin, try contacting the group admin",
        ),
      );
    });
  }

  Widget _getErrorWidget(String title, String description) {
    return Column(
      children: [
        const Icon(
          Icons.error,
          color: QPColors.errorFair,
          size: 32,
        ),
        const SizedBox(height: 28),
        Text(
          title,
          style: QPTextStyle.getHeading1SemiBold(context).copyWith(
            // Todo: check color based on theme
            color: QPColors.blackMassive,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          description,
          style: QPTextStyle.getBody2Regular(context).copyWith(
            // Todo: check color based on theme
            color: QPColors.neutral700,
          ),
        ),
        const SizedBox(height: 24),
        ButtonSecondary(
          label: "Close",
          onTap: () {
            Navigator.pop(context);
          },
          textStyle: QPTextStyle.getButton2SemiBold(context).copyWith(
            // Todo: check color based on theme
            color: QPColors.brandFair,
          ),
        ),
      ],
    );
  }
}

const double diameterButtonSearch = 65;

class ListSuratByJuz extends StatelessWidget {
  const ListSuratByJuz({
    Key? key,
    required this.notifier,
    required this.parentState,
  }) : super(key: key);

  final HomePageStateNotifier notifier;
  final HomePageState parentState;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        bool isLoggedIn = ref.watch(authenticationService).isLoggedIn;

        return Stack(
          children: <Widget>[
            ListView(
              children: [
                Container(
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.darkModeMassive,
                    light: QPColors.whiteFair,
                    brown: QPColors.brownModeRoot,
                    context: context,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: 200,
                        color: QPColors.getColorBasedTheme(
                          dark: QPColors.darkModeMassive,
                          light: QPColors.brandFair,
                          brown: QPColors.brownModeRoot,
                          context: context,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 16,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  StoredIcon.iconQuranPlus.path,
                                  colorFilter: ColorFilter.mode(
                                    QPColors.getColorBasedTheme(
                                      dark: QPColors.whiteFair,
                                      light: QPColors.whiteFair,
                                      brown: QPColors.brownModeMassive,
                                      context: context,
                                    ),
                                    BlendMode.srcIn,
                                  ),
                                  height: 32,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                SvgPicture.asset(
                                  ImagePath.quranPlusText,
                                  colorFilter: ColorFilter.mode(
                                    QPColors.getColorBasedTheme(
                                      dark: QPColors.whiteFair,
                                      light: QPColors.whiteFair,
                                      brown: QPColors.brownModeMassive,
                                      context: context,
                                    ),
                                    BlendMode.srcIn,
                                  ),
                                  height: 16,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            if (parentState.name != '')
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  "Assalamu’alaikum, ${parentState.name}",
                                  style: QPTextStyle.getSubHeading4SemiBold(
                                    context,
                                  ).copyWith(
                                    color: QPColors.getColorBasedTheme(
                                      dark: QPColors.whiteFair,
                                      light: QPColors.whiteMassive,
                                      brown: QPColors.brownModeMassive,
                                      context: context,
                                    ),
                                  ),
                                ),
                              ),
                            const AdzanCardWidget(),
                            const SizedBox(
                              height: 12,
                            ),
                            _buildHabitInformationCard(
                              context,
                              isLoggedIn,
                              parentState,
                              notifier,
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (parentState.juzElements == null ||
                    parentState.listTaddaburAvailables == null)
                  const _ListSurahByJuzSkeleton(),
                if (parentState.juzElements != null)
                  _buildSurahByJuzContainer(),
              ],
            ),
            Positioned(
              bottom: diameterButtonSearch * 2 / 6,
              right: diameterButtonSearch * 2 / 6,
              child: Container(
                width: diameterButtonSearch,
                height: diameterButtonSearch,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: darkGreen,
                ),
                child: _ButtonSearch(
                  versePagetoAyah: parentState.ayahPage,
                  state: parentState,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHabitInformationCard(
    BuildContext context,
    bool isLoggedIn,
    HomePageState state,
    HomePageStateNotifier notifier,
  ) {
    if (state.dailySummary == null) {
      return const DailyProgressTrackerSkeleton();
    }

    if (!isLoggedIn) {
      return const StartHabitCard();
    }

    if (isLoggedIn &&
        state.dailySummary!.totalPages <= 0 &&
        state.lastBookmark == null) {
      return _buildDailyHabitTracker(context, state);
    }

    return DailyProgressTrackerDetailCard(
      dailySummary: state.dailySummary!,
      isNeedSync: state.isNeedSync,
      lastBookmark: state.lastBookmark,
      lastTrackedData: state.lastRecordingData,
      onRefreshParentWidget: notifier.refreshDataOnPopFromSurahPage,
    );
  }

  Widget _buildDailyHabitTracker(BuildContext context, HomePageState state) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            DailyProgressTracker(
              target: state.dailySummary!.target,
              dailyProgress: state.dailySummary!.totalPages,
              isNeedSync: state.isNeedSync,
            ),
            const SizedBox(height: 20),
            ButtonSecondary(
              label: "See Details",
              onTap: () {
                final navigationBar =
                    mainNavbarGlobalKey.currentWidget as BottomNavigationBar;

                navigationBar.onTap!(1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahByJuzContainer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: parentState.juzElements!.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            Container(
              height: 42,
              alignment: Alignment.centerLeft,
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.surface),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                parentState.juzElements![index].name,
                textAlign: TextAlign.start,
                style: QPTextStyle.getBody1Regular(context),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 20, top: 16),
              color: QPColors.getColorBasedTheme(
                dark: QPColors.darkModeMassive,
                light: QPColors.whiteFair,
                brown: QPColors.brownModeRoot,
                context: context,
              ),
              child: _buildListSuratByJuz(
                context: context,
                juz: parentState.juzElements![index],
                notifier: notifier,
                state: parentState,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListSuratByJuz({
    required BuildContext context,
    required JuzElement juz,
    required HomePageStateNotifier notifier,
    required HomePageState state,
  }) {
    final List<SuratByJuz> surats = juz.surat;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: surats.length,
      itemBuilder: (context, index) {
        String surahNumberString = surats[index].number;

        int suratNumber = int.parse(surahNumberString);
        int? totalTadabburInSurah = state.listTaddaburAvailables == null
            ? null
            : state.listTaddaburAvailables![suratNumber];

        String surahNameLatin = surats[index].nameLatin;

        final bool hasTadabbur = state.listTaddaburAvailables == null
            ? false
            : state.listTaddaburAvailables!.containsKey(suratNumber);

        return _buildSuratItem(
          surats,
          index,
          context,
          notifier,
          state,
          hasTadabbur,
          surahNumberString,
          surahNameLatin,
          suratNumber,
          totalTadabburInSurah,
        );
      },
    );
  }

  Widget _buildSuratItem(
    List<SuratByJuz> surats,
    int index,
    BuildContext context,
    HomePageStateNotifier notifier,
    HomePageState state,
    bool hasTadabbur,
    String surahNumberString,
    String surahNameLatin,
    int suratNumber,
    int? totalTadabburInSurah,
  ) {
    return GestureDetector(
      onTap: () async {
        navigateToSurahPage(
          surats,
          index,
          context,
          notifier,
        );
      },
      child: Container(
        decoration: const BoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 8,
                right: 16,
                left: 24,
                bottom: hasTadabbur ? 0 : 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 34,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(
                            0,
                            0,
                            0,
                            0.1,
                          ),
                          offset: Offset(1.0, 2.0),
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      surahNumberString,
                      style: QPTextStyle.getSubHeading4Medium(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surahNameLatin,
                          style: QPTextStyle.getSubHeading3Medium(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            "Page ${surats[index].startPage}, Ayat ${surats[index].startAyat}",
                            style: QPTextStyle.getDescription2Regular(context)
                                .copyWith(color: Theme.of(context).hintColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 6.5,
                      right: 10,
                      bottom: 6.5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          surats[index].name,
                          style: suratFontStyle.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          child: state.audioSuratLoaded == surats[index]
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : IconButton(
                                  color: QPColors.getColorBasedTheme(
                                    dark: QPColors.brandFair,
                                    light: QPColors.brandFair,
                                    brown: QPColors.brandFair,
                                    context: context,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  alignment: Alignment.center,
                                  icon: const Icon(Icons.play_circle),
                                  iconSize: 20,
                                  onPressed: () async {
                                    onPlayAudioPressed(
                                      notifier,
                                      surats,
                                      index,
                                      context,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hasTadabbur)
              Padding(
                padding: const EdgeInsets.only(left: 60, right: 120, bottom: 8),
                child: ButtonPill(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.routeReadTadabbur,
                      arguments: ReadTadabburParam(
                        surahName: surahNameLatin,
                        surahId: suratNumber,
                      ),
                    );
                  },
                  label: "$totalTadabburInSurah Tadabbur available",
                  icon: Icons.menu_book,
                  colorText: QPColors.getColorBasedTheme(
                    dark: QPColors.whiteFair,
                    light: QPColors.brandFair,
                    brown: QPColors.brownModeMassive,
                    context: context,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> onPlayAudioPressed(
    HomePageStateNotifier notifier,
    List<SuratByJuz> surats,
    int index,
    BuildContext context,
  ) {
    return notifier.initAyahAudio(
      surat: surats[index],
      onSuccess: () => navigateToSurahPage(
        surats,
        index,
        context,
        notifier,
        isShowBottomSheet: true,
      ),
      onLoadError: () {
        GeneralBottomSheet.showNoInternetBottomSheet(
          context,
          () {
            Navigator.pop(context);
            onPlayAudioPressed(
              notifier,
              surats,
              index,
              context,
            );
          },
        );
      },
      onPlayBackError: () => showInitSurahAudioErrorSnackbar(
        context,
      ),
    );
  }

  void showInitSurahAudioErrorSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: QPColors.blackFair,
      padding: const EdgeInsets.only(left: 24),
      content: Row(
        children: [
          Expanded(
            child: Text(
              'An error has occured. Please try again.',
              style: QPTextStyle.getBody3Medium(context).copyWith(
                // Todo: check color based on theme
                color: QPColors.whiteMassive,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            padding: const EdgeInsets.all(3.33),
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            icon: const Icon(
              Icons.close,
              size: 16,
              color: QPColors.whiteMassive,
            ),
          ),
        ],
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> navigateToSurahPage(
    List<SuratByJuz> surats,
    int index,
    BuildContext context,
    HomePageStateNotifier notifier, {
    bool isShowBottomSheet = false,
  }) async {
    int page = surats[index].startPageToInt;
    int startPageInIndexValue = page - 1;

    final dynamic param = await Navigator.pushNamed(
      context,
      RoutePaths.routeSurahPage,
      arguments: SuratPageV3Param(
        startPageInIndex: startPageInIndexValue,
        firstPagePointerIndex: surats[index].startPageID,
        isShowBottomSheet: isShowBottomSheet,
      ),
    );

    if (param != null && param is SuratPageV3OnPopParam) {
      notifier.refreshDataOnPopFromSurahPage();
    }
  }
}

class _ButtonSearch extends StatelessWidget {
  const _ButtonSearch({
    Key? key,
    required this.versePagetoAyah,
    required this.state,
  }) : super(key: key);

  final Map<String, List<String>>? versePagetoAyah;
  final HomePageState state;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return IconButton(
          onPressed: () {
            GeneralSearchDialog.searchDialogByPageOrAyah(
              context,
              state.ayahPage ?? <String, List<String>>{},
            );
          },
          icon: const Icon(
            Icons.search_outlined,
            size: 37.0,
            color: neutral100,
          ),
        );
      },
    );
  }
}

class _ListSurahByJuzSkeleton extends StatelessWidget {
  const _ListSurahByJuzSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Shimmer.fromColors(
        baseColor: const Color.fromARGB(
          255,
          236,
          233,
          233,
        ),
        highlightColor: const Color.fromARGB(
          255,
          224,
          218,
          218,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.white,
            ),
            const SizedBox(
              height: 24,
            ),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.white,
            ),
            const SizedBox(
              height: 24,
            ),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.white,
            ),
            const SizedBox(
              height: 24,
            ),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.white,
            ),
            const SizedBox(
              height: 24,
            ),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.white,
            ),
            const SizedBox(
              height: 24,
            ),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
