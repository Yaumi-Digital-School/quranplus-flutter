import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/Icon.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/juz.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/widgets/daily_Progres_Tracker.dart';
import 'package:qurantafsir_flutter/widgets/searchDialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_page_state_notifier.dart';

StateNotifierProvider<HomePageStateNotifier, HomePageState>
    homePageStateNotifier =
    StateNotifierProvider<HomePageStateNotifier, HomePageState>(
  (ref) {
    return HomePageStateNotifier(
      sharedPreferenceService: ref.watch(sharedPreferenceServiceProvider),
    );
  },
);

class HomePageV2 extends StatelessWidget {
  const HomePageV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HomePageStateNotifier, HomePageState>(
      stateNotifierProvider: homePageStateNotifier,
      onStateNotifierReady: (notifier) async {
        await notifier.initStateNotifier();
      },
      builder: (
        BuildContext context,
        HomePageState state,
        HomePageStateNotifier notifier,
        _,
      ) {
        if (state.juzElements == null ||
            state.feedbackUrl == null ||
            state.ayahPage == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
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
                      width: 65,
                      height: 24,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'images/logo.png',
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
                    )
                  ],
                ),
              ),
              backgroundColor: backgroundColor,
            ),
          ),
          body: const ListSuratByJuz(),
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
  const ListSuratByJuz({Key? key}) : super(key: key);
  double diameterButtonSearch(BuildContext context) =>
      MediaQuery.of(context).size.width * 1 / 6;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        HomePageState state = ref.watch(homePageStateNotifier);
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
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          blurRadius: 15,
                          offset: Offset(4, 4))
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
                        const Padding(
                          padding: EdgeInsets.fromLTRB(15, 11, 15, 24),
                          child: DailyProgresTracker(
                            target: 1,
                            dailyProgres: 0.0,
                          ),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
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
                                      horizontal: 24),
                                  child: Text(
                                    state.juzElements![index].name,
                                    textAlign: TextAlign.start,
                                    style: bodyRegular1,
                                  ),
                                ),
                                _buildListSuratByJuz(
                                    context, state.juzElements![index]),
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
                    shape: BoxShape.circle, color: darkGreen),
                child: _ButtonSearch(
                  versePagetoAyah: state.ayahPage!,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildListSuratByJuz(BuildContext context, JuzElement juz) {
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
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      offset: Offset(1.0, 2.0),
                      blurRadius: 5.0,
                      spreadRadius: 1.0)
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
            onTap: () {
              int page = surats[index].startPageToInt;
              int startPageInIndexValue = page - 1;

              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: SuratPageV3(
                    startPageInIndex: startPageInIndexValue,
                    firstPagePointerIndex: surats[index].startPageID,
                  ),
                ),
              );
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
  }) : super(key: key);

  final Map<String, List<String>>? versePagetoAyah;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        HomePageState state = ref.watch(homePageStateNotifier);
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
