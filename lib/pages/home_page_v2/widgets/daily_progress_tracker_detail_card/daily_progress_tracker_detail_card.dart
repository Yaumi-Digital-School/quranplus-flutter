import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/last_recording_data.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/daily_progress_tracker.dart';
import 'package:shimmer/shimmer.dart';

class DailyProgressTrackerDetailCard extends StatelessWidget {
  const DailyProgressTrackerDetailCard({
    Key? key,
    required this.dailySummary,
    this.isNeedSync = false,
    this.lastTrackedData,
    this.lastBookmark,
    this.onRefreshParentWidget,
  }) : super(key: key);

  final HabitDailySummary dailySummary;
  final LastRecordingData? lastTrackedData;
  final Bookmarks? lastBookmark;
  final bool isNeedSync;
  final VoidCallback? onRefreshParentWidget;

  @override
  Widget build(BuildContext context) {
    if (lastBookmark != null || lastTrackedData != null) {
      return _buildDailyHabitTrackerWithHistoryData(context);
    }

    return _buildDailyHabitTracker(context);
  }

  Widget _buildDailyHabitTracker(BuildContext context) {
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
              target: dailySummary.target,
              dailyProgress: dailySummary.totalPages,
              isNeedSync: isNeedSync,
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

  Widget _buildDailyHabitTrackerWithHistoryData(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(now);

    final int dailyProgress = dailySummary.totalPages;
    final int target = dailySummary.target;
    final int dailyProgressToInt = dailyProgress.floor();

    double progress = dailyProgress / target;
    if (progress > 1) {
      progress = 1;
    }

    final int progressInPercentage = (progress * 100).round();

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Continue Reading',
                  style: QPTextStyle.getSubHeading2SemiBold(context),
                ),
                _buildSeeDetailCTA(context),
              ],
            ),
            Text(
              formattedDate,
              style: QPTextStyle.getDescription2Regular(context).copyWith(
                color: QPColors.getColorBasedTheme(
                  dark: QPColors.whiteRoot,
                  light: QPColors.blackFair,
                  brown: QPColors.brownModeMassive,
                  context: context,
                ),
              ),
            ),
            const SizedBox(
              height: 17,
            ),
            Row(
              children: [
                Expanded(
                  child: LinearPercentIndicator(
                    animation: true,
                    lineHeight: 16.0,
                    animationDuration: 1000,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    percent: progress,
                    barRadius: const Radius.circular(8),
                    progressColor: QPColors.brandFair,
                    backgroundColor: QPColors.brandRoot,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  '$progressInPercentage%',
                  style: QPTextStyle.getBody3Regular(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                target > 1
                    ? '$dailyProgressToInt/$target Pages'
                    : '$dailyProgressToInt/$target Page',
                style: QPTextStyle.getBody3Regular(context).copyWith(
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.whiteRoot,
                    light: QPColors.blackFair,
                    brown: QPColors.brownModeMassive,
                    context: context,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                if (lastTrackedData != null) ...[
                  Expanded(
                    child: _buildHistoryInfoBox(
                      title: 'Last Tracked',
                      icon: Icons.play_circle,
                      mainInfo: lastTrackedData!.surahName,
                      description: 'Page ${lastTrackedData!.page}',
                      startPageinIndex: lastTrackedData!.page - 1,
                      context: context,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                ],
                if (lastBookmark == null)
                  const Expanded(
                    child: SizedBox(),
                  ),
                if (lastBookmark != null)
                  Expanded(
                    child: _buildHistoryInfoBox(
                      title: 'Last Bookmark',
                      icon: Icons.bookmark,
                      mainInfo: lastBookmark!.surahName,
                      description: 'Page ${lastBookmark!.page}',
                      startPageinIndex: lastBookmark!.page - 1,
                      context: context,
                    ),
                  ),
                if (lastTrackedData == null)
                  const Expanded(
                    child: SizedBox(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryInfoBox({
    required String title,
    required IconData icon,
    required String mainInfo,
    required String description,
    required int startPageinIndex,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () async {
        final dynamic param = await Navigator.pushNamed(
          context,
          RoutePaths.routeSurahPage,
          arguments: SuratPageV3Param(
            startPageInIndex: startPageinIndex,
            isStartTracking: true,
          ),
        );

        if (onRefreshParentWidget != null &&
            param != null &&
            param is SuratPageV3OnPopParam) {
          onRefreshParentWidget!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: QPColors.brandFair,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: QPTextStyle.getDescription2Regular(context).copyWith(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.whiteHeavy,
                      light: QPColors.brandFair,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  mainInfo,
                  style: QPTextStyle.getButton2SemiBold(context).copyWith(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.whiteFair,
                      light: QPColors.blackFair,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                  ),
                ),
                Text(
                  description,
                  style: QPTextStyle.baseTextStyle.copyWith(
                    fontWeight: QPFontWeight.regular,
                    fontSize: 8,
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.blackRoot,
                      light: QPColors.blackFair,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeDetailCTA(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final navigationBar =
            mainNavbarGlobalKey.currentWidget as BottomNavigationBar;

        navigationBar.onTap!(1);
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: QPColors.getColorBasedTheme(
          dark: QPColors.blackHeavy,
          light: QPColors.whiteMassive,
          brown: QPColors.brownModeRoot,
          context: context,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          side: BorderSide(
            color: QPColors.getColorBasedTheme(
              dark: QPColors.blackFair,
              light: QPColors.whiteRoot,
              brown: QPColors.brownModeHeavy,
              context: context,
            ),
            width: 1,
          ),
        ),
      ),
      child: Text(
        'See Details',
        style: QPTextStyle.getSubHeading4SemiBold(context).copyWith(
          color: QPColors.getColorBasedTheme(
            dark: QPColors.whiteFair,
            light: QPColors.brandFair,
            brown: QPColors.brownModeMassive,
            context: context,
          ),
        ),
      ),
    );
  }
}

class DailyProgressTrackerSkeleton extends StatelessWidget {
  const DailyProgressTrackerSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 160,
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
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
      ),
    );
  }
}
