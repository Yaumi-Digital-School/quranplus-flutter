import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/add_daily_progress_manual/add_daily_progress_manual_view.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/change_daily_target/change_daily_target_view.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/widgets/adaptive_theme_dialog.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/daily_progress_tracker.dart';
import 'package:qurantafsir_flutter/widgets/utils/general_dialog.dart';

import 'habit_personal_state_notifier.dart';

class HabitPersonalView extends StatefulWidget {
  const HabitPersonalView({Key? key}) : super(key: key);

  @override
  State<HabitPersonalView> createState() => _HabitPersonalState();
}

class _HabitPersonalState extends State<HabitPersonalView> {
  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HabitPersonalStateNotifier,
        HabitPersonalState>(
      stateNotifierProvider:
          StateNotifierProvider<HabitPersonalStateNotifier, HabitPersonalState>(
        (StateNotifierProviderRef<HabitPersonalStateNotifier,
                HabitPersonalState>
            ref) {
          return HabitPersonalStateNotifier(
            habitDailySummaryService: ref.watch(habitDailySummaryService),
          );
        },
      ),
      onStateNotifierReady: (notifier, ref) async =>
          await notifier.initStateNotifier(),
      builder: (
        BuildContext context,
        HabitPersonalState state,
        HabitPersonalStateNotifier notifier,
        WidgetRef ref,
      ) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(
              height: 32,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Start your Reading Habit",
                    style: QPTextStyle.getSubHeading2SemiBold(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Now you can update and set your personal reading progress and target",
                    style: QPTextStyle.getSubHeading3Regular(context),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Card(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.darkModeFair,
                      light: QPColors.whiteMassive,
                      brown: QPColors.brownModeFair,
                      context: context,
                    ),
                    elevation: 1.2,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        16,
                        12,
                        24,
                      ),
                      child: Column(
                        children: [
                          Text(
                            state.currentMonth ?? "",
                            style: QPTextStyle.getSubHeading2SemiBold(context),
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
                              final BottomNavigationBar navbar =
                                  mainNavbarGlobalKey.currentWidget
                                      as BottomNavigationBar;
                              navbar.onTap!(3);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 9),
      decoration: BoxDecoration(
        color: QPColors.getColorBasedTheme(
          dark: Colors.transparent,
          light: Colors.transparent,
          brown: QPColors.brownModeRoot,
          context: context,
        ),
        border: isToday
            ? const Border.fromBorderSide(
                BorderSide(color: yellowBorder, width: 1),
              )
            : null,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(children: [
        Text(
          nameOfDay,
          style: QPTextStyle.getSubHeading3SemiBold(context),
        ),
        const SizedBox(height: 6),
        Image.asset(_buildUrlStar(progress, isToday)),
        const SizedBox(height: 6),
        Text(
          numberOfDay,
          style: QPTextStyle.getSubHeading3SemiBold(context),
        ),
      ]),
    );
  }

  Widget _buildProgressDaily(List<HabitDailySummary>? summary) {
    List<Widget> rowChildren = [];
    if (summary == null || summary.isEmpty) {
      return const Row();
    }
    for (HabitDailySummary item in summary) {
      rowChildren.add(_buildProgressDailyItem(item));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: rowChildren,
    );
  }

  void _showDialogChangeDailyTarget(
    HabitDailySummary currentProgress,
    HabitPersonalStateNotifier habitProgressStateNotifier,
  ) async {
    final isRefresh = await showQPGeneralDialog(
          context: context,
          builder: (BuildContext context) {
            return AdaptiveThemeDialog(
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
    HabitPersonalStateNotifier habitProgressStateNotifier,
  ) async {
    final isRefresh = await showQPGeneralDialog(
          context: context,
          builder: (context) {
            return AdaptiveThemeDialog(
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
