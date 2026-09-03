import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/read_tadabbur/read_tadabbur_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/page_tracker_bar.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_bottom_sheet_widget.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_minimized_info.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

/// The overlay shown on top of the quran pages: the recording tracker bar and
/// the bottom call-to-action (tadabbur + start-tracking buttons + minimized
/// audio player).
///
/// It does its own narrow watching so that swiping the underlying PageView (or
/// unrelated state changes) does not rebuild the overlay, and vice versa.
class SuratPageOverlay extends ConsumerWidget {
  const SuratPageOverlay({
    super.key,
    required this.onTapTrackerBar,
    required this.onTapStartTracking,
  });

  final VoidCallback onTapTrackerBar;
  final VoidCallback onTapStartTracking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isRecording = ref.watch(
      suratPageHabitProvider.select((s) => s.isRecording),
    );
    final bool isOnReadCTAVisible = ref.watch(
      suratPageHabitProvider.select((s) => s.isOnReadCTAVisible),
    );
    final bool showMinimizedAudioPlayer = ref.watch(
      suratPageHabitProvider.select((s) => s.showMinimizedAudioPlayer),
    );
    final String visibleSuratName = ref.watch(
      suratPageNavigationProvider.select((s) => s.visibleSuratName),
    );
    final Map<int, List<int>> availableAyahTadabburs = ref.watch(
      suratPageContentProvider.select((s) => s.availableAyahTadabburs),
    );
    final habitNotifier = ref.read(suratPageHabitProvider.notifier);

    final double bottomPadding = MediaQuery.of(context).size.height * 0.025;

    return Stack(
      children: [
        if (isRecording)
          Positioned(child: PageTrackerBar(onTap: onTapTrackerBar)),
        if (isOnReadCTAVisible)
          Positioned(
            bottom: bottomPadding,
            width: MediaQuery.of(context).size.width - 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) {
                          final surahNumber =
                              surahNameToSurahNumberMap[visibleSuratName] ?? 0;
                          if (availableAyahTadabburs[surahNumber] != null) {
                            return ButtonBrandSoft(
                              leftWidget: const Icon(
                                Icons.menu_book,
                                size: 12,
                                color: QPColors.brandFair,
                              ),
                              title: 'Tadabbur $visibleSuratName',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  RoutePaths.routeReadTadabbur,
                                  arguments: ReadTadabburParam(
                                    surahName: visibleSuratName,
                                    surahId: surahNumber,
                                    isFromSurahPage: true,
                                  ),
                                );
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      if (!isRecording)
                        ButtonPrimary(
                          label: 'Start Tracking',
                          size: ButtonSize.small,
                          onTap: onTapStartTracking,
                        ),
                    ],
                  ),
                  if (showMinimizedAudioPlayer) ...<Widget>[
                    const SizedBox(height: 20),
                    AudioMinimizedInfo(
                      onTapContainer: () {
                        GeneralBottomSheet.showBaseBottomSheet(
                          context: context,
                          widgetChild: const AudioBottomSheetWidget(),
                        );
                      },
                      onClose: () => habitNotifier.stopRecitation(),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
