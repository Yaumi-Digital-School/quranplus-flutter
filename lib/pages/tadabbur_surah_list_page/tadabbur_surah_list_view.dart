import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_surah_list_page/tadabbur_surah_list_view_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_surah_list_page/widgets/tadabbur_surah_card.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';

class TadabburSurahListView extends ConsumerWidget {
  const TadabburSurahListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tadabburSurahListViewProvider);

    if (state.isLoading) {
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
          elevation: 0.7,
          foregroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            'Tadabbur',
            style: QPTextStyle.getSubHeading2SemiBold(context),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
        ),
        child: ListView.builder(
          itemCount: state.tadabburSurahList!.length + 1,
          itemBuilder: ((context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Tadabbur Al-Quran',
                  style: QPTextStyle.getSubHeading2SemiBold(context),
                ),
              );
            }

            final GetTadabburSurahListItemResponse data =
                state.tadabburSurahList![index - 1];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TadabburSurahCard(
                title: data.surah.name,
                availableTadabbur: data.totalTadabbur,
                lastUpdatedAt: data.createdAt,
                surahID: data.surahID,
              ),
            );
          }),
        ),
      ),
    );
  }
}
