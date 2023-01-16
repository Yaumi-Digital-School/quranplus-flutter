import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_view.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/card_start_habit.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/Icon.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/models/juz.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart' as date_util;
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/alert_dialog.dart';
import 'package:qurantafsir_flutter/widgets/daily_progress_tracker.dart';
import 'package:qurantafsir_flutter/widgets/sign_in_bottom_sheet.dart';
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
        if (state.juzElements == null ||
            state.feedbackUrl == null ||
            state.ayahPage == null ||
            state.dailySummary == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (notifier.mainPageProvider
            .getShouldShowSignInBottomSheetAndReset()) {
          Future.delayed(Duration.zero, () {
            SignInBottomSheet.show(
              context: context,
              onClose: () {
                notifier.getAndRemoveForceLoginParam();
              },
              onTapSignInWithGoogle: () async {
                final bool isSuccess =
                    await ref.read(authenticationService).signInWithGoogle(ref);

                ForceLoginParam? param =
                    await notifier.getAndRemoveForceLoginParam();

                final HttpResponse<bool> req =
                    await ref.read(habitGroupApiProvider).joinGroup(
                          groupId: param?.arguments?['id'] ?? 0,
                          request: JoinHabitGroupRequest(
                            date: date_util.DateUtils.getCurrentDateInString(),
                          ),
                        );

                final bool shouldRedirect = isSuccess &&
                    req.response.statusCode == 200 &&
                    param != null;

                if (shouldRedirect) {
                  Object? args;
                  switch (param.nextPath) {
                    case RoutePaths.routeHabitGroupDetail:
                      args = HabitGroupDetailViewParam(
                        id: param.arguments?['id'],
                        groupName: param.arguments?['groupName'],
                      );
                  }

                  Navigator.pop(context);

                  Navigator.pushNamed(
                    context,
                    param.nextPath ?? '',
                    arguments: args,
                  );
                }

                setState(() {});
              },
            );
          });
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
            state: state,
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
}

class ListSuratByJuz extends StatelessWidget {
  const ListSuratByJuz({
    Key? key,
    required this.notifier,
    required this.state,
  }) : super(key: key);

  final HomePageStateNotifier notifier;
  final HomePageState state;
  double diameterButtonSearch(BuildContext context) =>
      MediaQuery.of(context).size.width * 1 / 6;
  // Temporary value to include/exclude habit in build
  final bool isHabitEnabled = true;
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
                    state.name.isNotEmpty
                        ? 'Assalamu’alaikum, ${state.name}'
                        : 'Assalamu’alaikum',
                    textAlign: TextAlign.start,
                    style: captionSemiBold1,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (isHabitEnabled)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              24,
                              16,
                              24,
                              24,
                            ),
                            child: isLoggedIn
                                ? _buildDailyHabitTracker(context, state)
                                : const StartHabitCard(),
                          ),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.juzElements!.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: <Widget>[
                                Container(
                                  height: 42,
                                  alignment: Alignment.centerLeft,
                                  decoration:
                                      const BoxDecoration(color: neutral200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Text(
                                    state.juzElements![index].name,
                                    textAlign: TextAlign.start,
                                    style: bodyRegular1,
                                  ),
                                ),
                                _buildListSuratByJuz(
                                  context: context,
                                  juz: state.juzElements![index],
                                  notifier: notifier,
                                ),
                              ],
                            );
                          },
                        ),
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
                  versePagetoAyah: state.ayahPage!,
                  state: state,
                ),
              ),
            ),
          ],
        );
      },
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
                    MainPage.globalKey.currentWidget as BottomNavigationBar;

                navigationBar.onTap!(1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSuratByJuz({
    required BuildContext context,
    required JuzElement juz,
    required HomePageStateNotifier notifier,
  }) {
    final List<SuratByJuz> surats = juz.surat;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: surats.length,
        itemBuilder: (context, index) {
          return ListTile(
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
                surats[index].number,
                style: numberStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            title: Text(
              surats[index].nameLatin,
              style: bodyMedium2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "Page ${surats[index].startPage}, Ayat ${surats[index].startAyat}",
              style: bodyLight3,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              surats[index].name,
              style: suratFontStyle,
              textAlign: TextAlign.right,
            ),
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
                if (param.isHabitDailySummaryChanged) {
                  notifier.getCurrentHabitDailySummaryListLocal();
                }
              }
            },
          );
        },
      ),
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
