import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/add_daily_progress_manual/add_daily_progress_manual_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_progress.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_progress.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/text_field.dart';

class AddDailyProgressManualView extends StatefulWidget {
  final HabitDailySummary habitDailySummary;
  const AddDailyProgressManualView({Key? key, required this.habitDailySummary})
      : super(key: key);

  @override
  State<AddDailyProgressManualView> createState() =>
      _AddDailyProgressManualViewState();
}

class _AddDailyProgressManualViewState
    extends State<AddDailyProgressManualView> {
  String inputPages = "0";
  @override
  Widget build(BuildContext context) {
    final target = widget.habitDailySummary.target;
    final totalPages = widget.habitDailySummary.totalPages;
    final formattedDate =
        DateFormat("EEEE, dd MMMM yyyy").format(widget.habitDailySummary.date);
    return StateNotifierConnector<AddDailyProgressManualStateNotifier,
        AddDailyProgressManualState>(
      stateNotifierProvider: StateNotifierProvider<
          AddDailyProgressManualStateNotifier, AddDailyProgressManualState>(
        (StateNotifierProviderRef<AddDailyProgressManualStateNotifier,
                AddDailyProgressManualState>
            ref) {
          return AddDailyProgressManualStateNotifier(
              habitDailySummary: widget.habitDailySummary);
        },
      ),
      onStateNotifierReady: (notifier) async =>
          await notifier.initStateNotifier(),
      builder: (
        BuildContext context,
        AddDailyProgressManualState state,
        AddDailyProgressManualStateNotifier notifier,
        WidgetRef ref,
      ) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: state.isLoading
              ? const SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You have read $totalPages of $target Pages today",
                      style: subHeadingSemiBold2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: bodyRegular3.copyWith(color: neutral600),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Progress History",
                      style: buttonMedium3,
                    ),
                    const SizedBox(height: 8),
                    state.progressHistory.isEmpty
                        ? Text(
                            "No progress yet",
                            style: regular8.copyWith(color: neutral600),
                          )
                        : Column(
                            children:
                                _buildProgressHistory(state.progressHistory),
                          ),
                    const SizedBox(height: 24),
                    Text(
                      "Add Manual Progress",
                      style: semiBold10,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        InputTotalPagesTextField(
                          onChanged: (value) {
                            inputPages = value;
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Pages",
                          style: regular10.copyWith(color: neutral600),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),
                    ButtonSecondary(
                      label: "Save",
                      textStyle: semiBold10.copyWith(color: darkGreen),
                      onTap: () async {
                        if (inputPages != "" && int.parse(inputPages) > 0) {
                          await notifier
                              .addDailyProgressManual(int.parse(inputPages));
                        }
                        Navigator.pop(context, true);
                      },
                    )
                  ],
                ),
        );
      },
    );
  }

  List<Widget> _buildProgressHistory(List<HabitProgress> progressHistory) {
    final List<Widget> result = [];
    for (HabitProgress element in progressHistory) {
      final inputTime = element.inputTime;
      final description = element.description;
      final type = element.type;
      final updateDesc = type == HabitProgressType.manual
          ? "Updated Manually"
          : "Updated by Reading";
      final content = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${inputTime.substring(0, inputTime.length - 3)} - $description",
            style: regular8.copyWith(fontWeight: light, color: neutral600),
          ),
          Text(
            updateDesc,
            style: regular8.copyWith(fontWeight: light, color: neutral600),
          ),
        ],
      );
      result.add(content);
    }
    return result;
  }
}
