import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/home_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/card_start_habit.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/daily_progress_tracker_detail_card/daily_progress_tracker_detail_card.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/daily_progress_tracker.dart';

class HomeHabitCard extends ConsumerWidget {
  const HomeHabitCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authenticationService).isLoggedIn;
    final dailySummary =
        ref.watch(homePageProvider.select((s) => s.dailySummary));
    final isNeedSync =
        ref.watch(homePageProvider.select((s) => s.isNeedSync));
    final lastBookmark =
        ref.watch(homePageProvider.select((s) => s.lastBookmark));
    final lastRecordingData =
        ref.watch(homePageProvider.select((s) => s.lastRecordingData));
    final notifier = ref.read(homePageProvider.notifier);

    if (dailySummary == null) {
      return const DailyProgressTrackerSkeleton();
    }

    if (!isLoggedIn) {
      return const StartHabitCard();
    }

    if (dailySummary.totalPages <= 0 && lastBookmark == null) {
      return _DailyHabitTracker(
        target: dailySummary.target,
        dailyProgress: dailySummary.totalPages,
        isNeedSync: isNeedSync,
      );
    }

    return DailyProgressTrackerDetailCard(
      dailySummary: dailySummary,
      isNeedSync: isNeedSync,
      lastBookmark: lastBookmark,
      lastTrackedData: lastRecordingData,
      onRefreshParentWidget: notifier.refreshDataOnPopFromSurahPage,
    );
  }
}

class _DailyHabitTracker extends StatelessWidget {
  const _DailyHabitTracker({
    required this.target,
    required this.dailyProgress,
    required this.isNeedSync,
  });

  final int target;
  final int dailyProgress;
  final bool isNeedSync;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              target: target,
              dailyProgress: dailyProgress,
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
}
