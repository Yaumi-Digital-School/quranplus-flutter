import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/home_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/home_surah_item.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/models/juz.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

class HomeSurahList extends ConsumerWidget {
  const HomeSurahList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final juzElements =
        ref.watch(homePageProvider.select((s) => s.juzElements));
    final tadabburMap =
        ref.watch(homePageProvider.select((s) => s.listTaddaburAvailables));
    final notifier = ref.read(homePageProvider.notifier);

    if (juzElements == null || tadabburMap == null) {
      return const _HomeSurahListSkeleton();
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: juzElements.length,
      itemBuilder: (context, index) {
        final juz = juzElements[index];
        return Column(
          children: [
            Container(
              height: 42,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                juz.name,
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
              child: _buildSuratsByJuz(
                context: context,
                juz: juz,
                tadabburMap: tadabburMap,
                notifier: notifier,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuratsByJuz({
    required BuildContext context,
    required JuzElement juz,
    required Map<int, int> tadabburMap,
    required HomePageNotifier notifier,
  }) {
    final surats = juz.surat;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: surats.length,
      itemBuilder: (context, index) {
        final surat = surats[index];
        final suratNumber = int.parse(surat.number);
        final hasTadabbur = tadabburMap.containsKey(suratNumber);

        return HomeSurahItem(
          surat: surat,
          hasTadabbur: hasTadabbur,
          totalTadabburInSurah: tadabburMap[suratNumber],
          onTap: () => _navigateToSurahPage(
            surats,
            index,
            context,
            notifier,
          ),
          onPlayTap: () => _onPlayAudioPressed(
            notifier,
            surats,
            index,
            context,
          ),
        );
      },
    );
  }

  Future<void> _onPlayAudioPressed(
    HomePageNotifier notifier,
    List<SuratByJuz> surats,
    int index,
    BuildContext context,
  ) {
    return notifier.initAyahAudio(
      surat: surats[index],
      onSuccess: () => _navigateToSurahPage(
        surats,
        index,
        context,
        notifier,
        isShowBottomSheet: true,
      ),
      onLoadError: () {
        GeneralBottomSheet.showNoInternetBottomSheet(context, () {
          Navigator.pop(context);
          _onPlayAudioPressed(notifier, surats, index, context);
        });
      },
      onPlayBackError: () => _showAudioErrorSnackbar(context),
    );
  }

  void _showAudioErrorSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: QPColors.blackFair,
      padding: const EdgeInsets.only(left: 24),
      content: Row(
        children: [
          Expanded(
            child: Text(
              'An error has occured. Please try again.',
              style: QPTextStyle.getBody3Medium(
                context,
              ).copyWith(color: QPColors.whiteMassive),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            padding: const EdgeInsets.all(3.33),
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            icon: const Icon(
              Icons.close,
              size: 16,
              color: QPColors.whiteMassive,
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _navigateToSurahPage(
    List<SuratByJuz> surats,
    int index,
    BuildContext context,
    HomePageNotifier notifier, {
    bool isShowBottomSheet = false,
  }) async {
    final int startPageInIndexValue = surats[index].startPageToInt - 1;

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

class _HomeSurahListSkeleton extends StatelessWidget {
  const _HomeSurahListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Shimmer.fromColors(
        baseColor: const Color.fromARGB(255, 236, 233, 233),
        highlightColor: const Color.fromARGB(255, 224, 218, 218),
        child: Column(
          children: [
            Container(width: double.infinity, height: 100, color: Colors.white),
            const SizedBox(height: 24),
            Container(width: double.infinity, height: 100, color: Colors.white),
            const SizedBox(height: 24),
            Container(width: double.infinity, height: 100, color: Colors.white),
            const SizedBox(height: 24),
            Container(width: double.infinity, height: 100, color: Colors.white),
            const SizedBox(height: 24),
            Container(width: double.infinity, height: 100, color: Colors.white),
            const SizedBox(height: 24),
            Container(width: double.infinity, height: 100, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
