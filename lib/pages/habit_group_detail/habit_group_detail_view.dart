import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';

class HabitGroupDetailView extends StatelessWidget {
  const HabitGroupDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HabitGroupDetailStateNotifier,
        HabitGroupDetailState>(
      stateNotifierProvider: StateNotifierProvider<
          HabitGroupDetailStateNotifier, HabitGroupDetailState>(
        (ref) {
          return HabitGroupDetailStateNotifier();
        },
      ),
      onStateNotifierReady: (notifier) async {
        notifier.initStateNotifier();
      },
      builder: (_, state, notifier, __) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(54.0),
            child: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: QPColors.blackMassive,
                  size: 30,
                ),
                onPressed: () {
                  // Navigator.pop(context);
                },
              ),
              automaticallyImplyLeading: false,
              elevation: 0.7,
              centerTitle: true,
              title: Text(
                'Temporary Nama Group',
                style: QPTextStyle.subHeading2SemiBold,
              ),
              backgroundColor: QPColors.whiteFair,
            ),
          ),
        );
      },
    );
  }
}
