import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_seven_days_item.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/widgets/daily_progress_tracker.dart';

import 'habit_progress_state_notifier.dart';

class HabitProgress extends StatelessWidget {
  const HabitProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HabitProgressStateNotifier,
            HabitProgressState>(
        stateNotifierProvider: StateNotifierProvider<HabitProgressStateNotifier,
            HabitProgressState>(
          (StateNotifierProviderRef<HabitProgressStateNotifier,
                  HabitProgressState>
              ref) {
            return HabitProgressStateNotifier();
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
          if (state.isLoading == null || state.isLoading!) {
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
                        fontSize: 16, color: neutral900, fontWeight: semiBold),
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
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                          const SizedBox(height: 16),
                          state.currentProgress != null
                              ? DailyProgressTracker(
                                  target: state.currentProgress!.target!,
                                  dailyProgress:
                                      state.currentProgress!.totalPage!)
                              : const DailyProgressTracker(
                                  target: 1, dailyProgress: 0),
                          const SizedBox(height: 24),
                          _button("Change Target", () {}),
                          const SizedBox(height: 16),
                          _button("Add Progress Manually", () {}),
                          const SizedBox(height: 16),
                          _button("Add Progress by Reading", () {}),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  String _buildUrlStar(double progress, bool isToday) {
    String additionalStr = isToday ? "" : "in";
    if (progress < 0.25) {
      return "images/${additionalStr}active_progress_0.png";
    }
    if (progress < 0.5) {
      return "images/${additionalStr}active_progress_25.png";
    }
    if (progress < 0.75) {
      return "images/${additionalStr}active_progress_50.png";
    }
    if (progress < 1) {
      return "images/${additionalStr}active_progress_75.png";
    }
    return "images/${additionalStr}active_progress_100.png";
  }

  Widget _button(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: darkGreen, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: bodySemibold2.copyWith(color: darkGreen),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDailyItem(HabitDailySevenDaysItem item) {
    final nameOfDay = DateFormat('EEEE').format(item.date).substring(0, 3);
    final numberOfDay = DateFormat('d').format(item.date);
    final now = DateTime.now();
    final isToday = now.difference(item.date).inDays == 0;
    double progress = 0;

    if (item.target != 0) {
      progress = item.totalPages / item.target;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: isToday
            ? BoxDecoration(
                border: Border.all(color: yellowBorder, width: 1),
                borderRadius: BorderRadius.circular(8),
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

  Widget _buildProgressDaily(List<HabitDailySevenDaysItem>? summary) {
    List<Widget> rowChildren = [];
    if (summary == null || summary.isEmpty) {
      return Row();
    }
    for (HabitDailySevenDaysItem item in summary) {
      rowChildren.add(_buildProgressDailyItem(item));
    }

    return Row(
      children: rowChildren,
    );
  }
}
