import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/Select_Reciter_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';

class SelectRecitatorWidget extends ConsumerStatefulWidget {
  const SelectRecitatorWidget(this.idReciter, {Key? key}) : super(key: key);

  final int? idReciter;

  @override
  ConsumerState<SelectRecitatorWidget> createState() =>
      _SelectRecitatorWidgetState();
}

class _SelectRecitatorWidgetState extends ConsumerState<SelectRecitatorWidget> {
  @override
  Widget build(BuildContext context) {
    final SelectReciterBottomSheetState selectReciterState =
        ref.watch(SelectReciterBottomSheetProvider);

    print(selectReciterState.listReciter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 32,
        ),
        Text(
          "Select Reciter",
          style: QPTextStyle.getSubHeading2SemiBold(context),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          "Select available reciter for audio recitation",
          style: QPTextStyle.getBody3Regular(context),
        ),
        const SizedBox(
          height: 24,
        ),
        Container(
          height: 54,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 0.6,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.radio_button_checked),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Abdur-Rahman as-Sudais",
                  style: QPTextStyle.getSubHeading3Medium(context),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.play_circle_outline),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
        ),
        ButtonSecondary(label: "Save", onTap: () {}),
      ],
    );
  }
}
