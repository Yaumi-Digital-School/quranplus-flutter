import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/change_daily_target/change_daily_target_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/text_field.dart';

const list = ['Pages', 'Juz'];

class ChangeDailyTargetView extends StatefulWidget {
  final HabitDailySummary habitDailySummary;
  const ChangeDailyTargetView({
    Key? key,
    required this.habitDailySummary,
  }) : super(key: key);

  @override
  State<ChangeDailyTargetView> createState() => _ChangeDailyTargetViewState();
}

class _ChangeDailyTargetViewState extends State<ChangeDailyTargetView> {
  String inputUser = "1";
  String typeTarget = "Pages";

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<ChangeDailyTargetStateNotifier,
        ChangeDailyTargetState>(
      stateNotifierProvider: StateNotifierProvider<
          ChangeDailyTargetStateNotifier, ChangeDailyTargetState>(
        (StateNotifierProviderRef<ChangeDailyTargetStateNotifier,
                ChangeDailyTargetState>
            ref) {
          return ChangeDailyTargetStateNotifier(
            habitDailySummary: widget.habitDailySummary,
          );
        },
      ),
      onStateNotifierReady: (notifier, ref) async =>
          await notifier.initStateNotifier(),
      builder: (
        BuildContext context,
        ChangeDailyTargetState state,
        ChangeDailyTargetStateNotifier notifier,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Set your daily target',
                      style: QPTextStyle.getSubHeading1SemiBold(context),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Set a daily reading target to motivate and help you stay active.',
                      style: TextStyle(
                        fontWeight: regular,
                        fontSize: 12,
                        color: neutral500,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Daily Target',
                      style: TextStyle(fontWeight: semiBold, fontSize: 12),
                    ),
                    const SizedBox(
                      height: 9,
                    ),
                    Row(
                      children: [
                        InputTotalPagesTextField(
                          defaultValue: int.parse(inputUser),
                          onChanged: (value) {
                            inputUser = value;
                          },
                        ),
                        const SizedBox(width: 8),
                        DropDownListChangeTarget(
                          onChanged: (type) {
                            notifier.changeTargetType(type);
                            typeTarget = type;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (state.targetType == 'Juz') ...<Widget>[
                      Text(
                        '1 juz means 20 pages',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: regular,
                          color: neutral500,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Changing this will only apply to today and future targets',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: regular,
                        color: neutral500,
                      ),
                    ),
                    const SizedBox(height: 13),
                    ButtonSecondary(
                      label: 'Save',
                      onTap: () async {
                        if (inputUser != "" && int.parse(inputUser) > 0) {
                          await notifier.changeDailyTarget(
                            int.parse(inputUser),
                            typeTarget,
                          );
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
}

class DropDownListChangeTarget extends StatefulWidget {
  final void Function(String) onChanged;

  const DropDownListChangeTarget({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<DropDownListChangeTarget> createState() =>
      DropDownListChangeTargetState();
}

class DropDownListChangeTargetState extends State<DropDownListChangeTarget> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: neutral500, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          elevation: 16,
          value: dropdownValue,
          style: TextStyle(color: neutral600, fontSize: 12, fontWeight: medium),
          icon: const Icon(
            Icons.arrow_drop_down,
            size: 15,
          ),
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              dropdownValue = value!;
              widget.onChanged(value);
            });
          },
          items: list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Text(value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
