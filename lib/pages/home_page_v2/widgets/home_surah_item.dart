import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/home_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/read_tadabbur/read_tadabbur_page.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/juz.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';

class HomeSurahItem extends ConsumerWidget {
  const HomeSurahItem({
    super.key,
    required this.surat,
    required this.hasTadabbur,
    required this.totalTadabburInSurah,
    required this.onTap,
    required this.onPlayTap,
  });

  final SuratByJuz surat;
  final bool hasTadabbur;
  final int? totalTadabburInSurah;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAudioLoading = ref.watch(
      homePageProvider.select((s) => s.audioSuratLoaded == surat),
    );

    final surahNameLatin = surat.nameLatin;
    final suratNumber = int.parse(surat.number);

    return GestureDetector(
      onTap: onTap,
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
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          offset: Offset(1.0, 2.0),
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Text(
                      surat.number,
                      style: QPTextStyle.getSubHeading4Medium(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                            "Page ${surat.startPage}, Ayat ${surat.startAyat}",
                            style: QPTextStyle.getDescription2Regular(
                              context,
                            ).copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
                          surat.name,
                          style: suratFontStyle.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(width: 10),
                        isAudioLoading
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
                                onPressed: onPlayTap,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hasTadabbur)
              Padding(
                padding:
                    const EdgeInsets.only(left: 60, right: 120, bottom: 8),
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
}
