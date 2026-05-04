import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/home_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/widgets/alert_dialog.dart';

const double kHomeSearchButtonDiameter = 65;

class HomeSearchButton extends ConsumerWidget {
  const HomeSearchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahPage =
        ref.watch(homePageProvider.select((s) => s.ayahPage));

    return Container(
      width: kHomeSearchButtonDiameter,
      height: kHomeSearchButtonDiameter,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: darkGreen,
      ),
      child: IconButton(
        onPressed: () {
          GeneralSearchDialog.searchDialogByPageOrAyah(
            context,
            ayahPage ?? <String, List<String>>{},
          );
        },
        icon: const Icon(
          Icons.search_outlined,
          size: 37.0,
          color: neutral100,
        ),
      ),
    );
  }
}
