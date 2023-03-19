import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_view.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/card_start_habit.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/daily_progress_tracker_detail_card/daily_progress_tracker_detail_card.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/pages/read_tadabbur/read_tadabbur_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/Icon.dart';
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
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/alert_dialog.dart';
import 'package:qurantafsir_flutter/widgets/daily_progress_tracker.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/sign_in_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:retrofit/retrofit.dart';
import 'home_page_state_notifier.dart';

class HomePageV2 extends StatefulWidget {
  const HomePageV2({Key? key}) : super(key: key);

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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(54.0),
            child: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0.5,
              centerTitle: false,
              foregroundColor: primary500,
              title: Transform.translate(
                offset: const Offset(8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 110,
                      height: 28,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            ImagePath.logoQuranPlusLandscape,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: IconButton(
                        onPressed: () => _launchUrl(state.feedbackUrl),
                        icon: Image.asset(
                          IconPath.iconForm,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: backgroundColor,
            ),
          ),
          body: ListSuratByJuz(
            notifier: notifier,
            parentState: state,
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String? url) async {
    final Uri _url = Uri.parse(url ?? '');
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
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
          ref: ref,
          type: type,
        );

    if (result == SignInResult.failedAccountDeleted) {
      Navigator.pop(context);
      await Future.delayed(const Duration(seconds: 1), () {
        SignInBottomSheet.showAccountDeletedInfo(context: context);
      });

      return;
    }

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

      Navigator.pushNamed(
        context,
        param.nextPath ?? '',
        arguments: args,
      );
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
          style: QPTextStyle.heading1SemiBold.copyWith(
            color: QPColors.blackMassive,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          description,
          style: QPTextStyle.body2Regular.copyWith(
            color: QPColors.neutral700,
          ),
        ),
        const SizedBox(height: 24),
        ButtonSecondary(
          label: "Close",
          onTap: () {
            Navigator.pop(context);
          },
          textStyle:
              QPTextStyle.button2SemiBold.copyWith(color: QPColors.brandFair),
        ),
      ],
    );
  }
}

class ListSuratByJuz extends StatelessWidget {
  const ListSuratByJuz({
    Key? key,
    required this.notifier,
    required this.parentState,
  }) : super(key: key);

  final HomePageStateNotifier notifier;
  final HomePageState parentState;

  double diameterButtonSearch(BuildContext context) =>
      MediaQuery.of(context).size.width * 1 / 6;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        bool isLoggedIn = ref.watch(authenticationService).isLoggedIn;

        return Stack(
          children: <Widget>[
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(
                          0,
                          0,
                          0,
                          0.08,
                        ),
                        blurRadius: 15,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    parentState.name.isNotEmpty
                        ? 'Assalamu’alaikum, ${parentState.name}'
                        : 'Assalamu’alaikum',
                    textAlign: TextAlign.start,
                    style: captionSemiBold1,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            24,
                            16,
                            24,
                            24,
                          ),
                          child: _buildHabitInformationCard(
                            context,
                            isLoggedIn,
                            parentState,
                            notifier,
                          ),
                        ),
                        if (parentState.juzElements == null ||
                            parentState.listTaddaburAvailables == null)
                          const _ListSurahByJuzSkeleton(),
                        if (parentState.juzElements != null)
                          _buildSurahByJuzContainer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: diameterButtonSearch(context) * 2 / 6,
              right: diameterButtonSearch(context) * 2 / 6,
              child: Container(
                width: diameterButtonSearch(context),
                height: diameterButtonSearch(context),
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
    return Card(
      color: Colors.white,
      elevation: 1.2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
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
              decoration: const BoxDecoration(color: neutral200),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                parentState.juzElements![index].name,
                textAlign: TextAlign.start,
                style: bodyRegular1,
              ),
            ),
            _buildListSuratByJuz(
              context: context,
              juz: parentState.juzElements![index],
              notifier: notifier,
              state: parentState,
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
        int? totalTadabburInSurah = state.listTaddaburAvailables![suratNumber];

        String surahNameLatin = surats[index].nameLatin;

        final bool hasTadabbur =
            state.listTaddaburAvailables!.containsKey(suratNumber);

        return GestureDetector(
          onTap: () async {
            int page = surats[index].startPageToInt;
            int startPageInIndexValue = page - 1;

            final dynamic param = await Navigator.pushNamed(
              context,
              RoutePaths.routeSurahPage,
              arguments: SuratPageV3Param(
                startPageInIndex: startPageInIndexValue,
                firstPagePointerIndex: surats[index].startPageID,
              ),
            );

            if (param != null && param is SuratPageV3OnPopParam) {
              notifier.refreshDataOnPopFromSurahPage();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                tileColor: backgroundColor,
                minLeadingWidth: 20,
                leading: Container(
                  alignment: Alignment.center,
                  height: 34,
                  width: 30,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
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
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    surahNumberString,
                    style: numberStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                title: Text(
                  surahNameLatin,
                  style: bodyMedium2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    "Page ${surats[index].startPage}, Ayat ${surats[index].startAyat}",
                    style: bodyLight3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Text(
                  surats[index].name,
                  style: suratFontStyle,
                  textAlign: TextAlign.right,
                ),
              ),
              if (hasTadabbur)
                Container(
                  color: QPColors.whiteFair,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 0, left: 60, right: 120),
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
                    ),
                  ),
                ),
              if (index == surats.length - 1 && hasTadabbur)
                const SizedBox(
                  height: 24,
                ),
            ],
          ),
        );
      },
    );
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
        child: SingleChildScrollView(
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
      ),
    );
  }
}
