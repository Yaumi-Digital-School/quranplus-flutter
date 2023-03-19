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

    return _buildDailyHabitTracker();
  }

  Widget _buildDailyHabitTracker() {
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

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
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
                  style: QPTextStyle.subHeading2SemiBold.copyWith(
                    color: QPColors.blackHeavy,
                  ),
                ),
                _buildSeeDetailCTA(),
              ],
            ),
            Text(
              formattedDate,
              style: QPTextStyle.description2Regular.copyWith(
                color: QPColors.blackFair,
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
                  style: QPTextStyle.body3Regular,
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
                style: QPTextStyle.body3Regular
                    .copyWith(color: QPColors.blackFair),
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
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
          color: QPColors.whiteHeavy,
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
                  style: QPTextStyle.description2Regular.copyWith(
                    color: QPColors.brandFair,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  mainInfo,
                  style: QPTextStyle.button2SemiBold.copyWith(
                    color: QPColors.blackFair,
                  ),
                ),
                Text(
                  description,
                  style: QPTextStyle.baseTextStyle.copyWith(
                    fontWeight: QPFontWeight.regular,
                    fontSize: 8,
                    color: QPColors.blackFair,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeDetailCTA() {
    return ElevatedButton(
      onPressed: () {
        final navigationBar =
            mainNavbarGlobalKey.currentWidget as BottomNavigationBar;

        navigationBar.onTap!(1);
      },
      child: Text(
        'See Details',
        style: QPTextStyle.subHeading4SemiBold.copyWith(
          color: QPColors.brandFair,
        ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          side: BorderSide(
            color: QPColors.whiteRoot,
          ),
        ),
        primary: Colors.white,
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
        child: const Card(
          elevation: 1.2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
      ),
    );
  }
}
