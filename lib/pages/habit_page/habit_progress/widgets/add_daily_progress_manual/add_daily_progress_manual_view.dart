import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/add_daily_progress_manual/add_daily_progress_manual_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
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
            habitDailySummary: widget.habitDailySummary,
          );
        },
      ),
      onStateNotifierReady: (notifier, ref) async =>
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
                      style: QPTextStyle.getSubHeading3SemiBold(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: QPTextStyle.getDescription2Regular(context),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Progress History",
                      style: QPTextStyle.getSubHeading4Medium(context),
                    ),
                    const SizedBox(height: 8),
                    state.progressHistory.isEmpty
                        ? Text(
                            "No progress yet",
                            style: QPTextStyle.getDescription2Regular(context),
                          )
                        : Column(
                            children:
                                _buildProgressHistory(state.progressHistory),
                          ),
                    const SizedBox(height: 24),
                    Text(
                      "Add Manual Progress",
                      style: QPTextStyle.getSubHeading4Medium(context),
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
                          style: QPTextStyle.getDescription2Regular(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ButtonSecondary(
                      label: "Save",
                      onTap: () async {
                        if (inputPages != "" && int.parse(inputPages) > 0) {
                          await notifier
                              .addDailyProgressManual(int.parse(inputPages));
                        }
                        Navigator.pop(context, true);
                      },
                    ),
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

      final Color textColor = QPColors.getColorBasedTheme(
        dark: QPColors.blackRoot,
        light: QPColors.blackMassive,
        brown: QPColors.brownModeMassive,
        context: context,
      );

      final content = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${inputTime.substring(0, inputTime.length - 3)} - $description",
            style: QPTextStyle.getCaption(context).copyWith(
              color: textColor,
            ),
          ),
          Text(
            updateDesc,
            style: QPTextStyle.getCaption(context).copyWith(
              color: textColor,
            ),
          ),
        ],
      );
      result.add(content);
    }

    return result;
  }
}
