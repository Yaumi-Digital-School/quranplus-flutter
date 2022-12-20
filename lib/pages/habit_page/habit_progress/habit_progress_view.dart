import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/change_daily_target/change_daily_target_view.dart';
import 'package:qurantafsir_flutter/pages/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/daily_progress_tracker.dart';

import 'habit_progress_state_notifier.dart';
import 'widgets/add_daily_progress_manual/add_daily_progress_manual_view.dart';

class HabitProgressView extends StatefulWidget {
  const HabitProgressView({Key? key}) : super(key: key);

  @override
  State<HabitProgressView> createState() => _HabitProgressState();
}

class _HabitProgressState extends State<HabitProgressView> {
  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HabitProgressStateNotifier,
        HabitProgressState>(
      stateNotifierProvider:
          StateNotifierProvider<HabitProgressStateNotifier, HabitProgressState>(
        (StateNotifierProviderRef<HabitProgressStateNotifier,
                HabitProgressState>
            ref) {
          return HabitProgressStateNotifier(
            habitDailySummaryService: ref.watch(habitDailySummaryService),
          );
        },
      ),
      onStateNotifierReady: (notifier) async =>
          await notifier.initStateNotifier(),
      builder: (
        BuildContext context,
        HabitProgressState state,
        HabitProgressStateNotifier notifier,
        WidgetRef ref,
      ) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Text(
                  "Start your Reading Habit",
                  style: TextStyle(
                    fontSize: 16,
                    color: neutral900,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Now you can update and set your personal reading progress and target",
                  style: TextStyle(fontSize: 14, color: neutral600),
                ),
                const SizedBox(
                  height: 24,
                ),
                Card(
                  color: Colors.white,
                  elevation: 1.2,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      24,
                    ),
                    child: Column(
                      children: [
                        Text(
                          state.currentMonth ?? "",
                          style: subHeadingSemiBold2,
                        ),
                        const SizedBox(height: 24),
                        _buildProgressDaily(state.lastSevenDays),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: neutral300,
                        ),
                        const SizedBox(height: 20),
                        state.currentProgress != null
                            ? DailyProgressTracker(
                                target: state.currentProgress!.target,
                                dailyProgress:
                                    state.currentProgress!.totalPages,
                                isNeedSync: state.isNeedSync,
                              )
                            : DailyProgressTracker(
                                target: 1,
                                dailyProgress: 0,
                                isNeedSync: state.isNeedSync,
                              ),
                        const SizedBox(height: 24),
                        ButtonNeutral(
                          label: "Change Target",
                          onTap: () {
                            _showDialogChangeDailyTarget(
                              state.currentProgress!,
                              notifier,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        ButtonNeutral(
                          label: "Add Progress Manually",
                          onTap: () {
                            _showDialogAddDailyProgress(
                              state.currentProgress!,
                              notifier,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        ButtonNeutral(
                          label: "Add Progress by Reading",
                          onTap: () {
                            final BottomNavigationBar navbar = MainPage
                                .globalKey.currentWidget as BottomNavigationBar;
                            navbar.onTap!(2);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _buildUrlStar(double progress, bool isToday) {
    String additionalStr = isToday ? "" : "in";
    if (progress == 0) {
      return "images/${additionalStr}active_progress_0.png";
    }
    if (progress < 1) {
      return "images/${additionalStr}active_progress_50.png";
    }

    return "images/${additionalStr}active_progress_100.png";
  }

  Widget _buildProgressDailyItem(HabitDailySummary item) {
    final nameOfDay = DateFormat('EEEE').format(item.date).substring(0, 3);
    final numberOfDay = DateFormat('d').format(item.date);
    final now = DateTime.now();
    final cleanDate = DateTime(now.year, now.month, now.day);
    final isToday = cleanDate.difference(item.date).inDays == 0;
    double progress = 0;

    if (item.target != 0) {
      progress = item.totalPages / item.target;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: isToday
            ? const BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(color: yellowBorder, width: 1),
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              )
            : null,
        child: Column(children: [
          Text(nameOfDay),
          const SizedBox(height: 6),
          Image.asset(_buildUrlStar(progress, isToday)),
          const SizedBox(height: 6),
          Text(numberOfDay),
        ]),
      ),
    );
  }

  Widget _buildProgressDaily(List<HabitDailySummary>? summary) {
    List<Widget> rowChildren = [];
    if (summary == null || summary.isEmpty) {
      return Row();
    }
    for (HabitDailySummary item in summary) {
      rowChildren.add(_buildProgressDailyItem(item));
    }

    return Row(
      children: rowChildren,
    );
  }

  void _showDialogChangeDailyTarget(
    HabitDailySummary currentProgress,
    HabitProgressStateNotifier habitProgressStateNotifier,
  ) async {
    final isRefresh = await showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: brokenWhite,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: ChangeDailyTargetView(
                habitDailySummary: currentProgress,
              ),
            );
          },
        ) ??
        false;
    if (isRefresh) {
      await habitProgressStateNotifier.fetchData();
    }
  }

  void _showDialogAddDailyProgress(
    HabitDailySummary currentProgress,
    HabitProgressStateNotifier habitProgressStateNotifier,
  ) async {
    final isRefresh = await showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: brokenWhite,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: AddDailyProgressManualView(
                habitDailySummary: currentProgress,
              ),
            );
          },
        ) ??
        false;
    if (isRefresh) {
      await habitProgressStateNotifier.fetchData();
    }
  }
}
