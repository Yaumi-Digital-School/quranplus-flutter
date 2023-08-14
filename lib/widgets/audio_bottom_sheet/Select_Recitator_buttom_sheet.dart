import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/audio.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/Select_Reciter_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';

class SelectRecitatorWidget extends ConsumerStatefulWidget {
  const SelectRecitatorWidget(this.idReciter, {Key? key}) : super(key: key);

  final int? idReciter;

  @override
  ConsumerState<SelectRecitatorWidget> createState() =>
      _SelectRecitatorWidgetState();
}

enum SingingCharacter { lafayette, jefferson }

class _SelectRecitatorWidgetState extends ConsumerState<SelectRecitatorWidget> {
  int id = 1; //harus dibuat dinamis sesuai dengan pilihan akhir user
  String nameReciter = "Mishari Rashid Al-Afasy";
  @override
  Widget build(BuildContext context) {
    final SelectReciterBottomSheetState selectReciterState =
        ref.watch(SelectReciterBottomSheetProvider);

    print(selectReciterState.listReciter);

    return SizedBox(
      height: 450,
      child: Column(
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
          SizedBox(
            height: 258,
            child: _buildChangeReciterWidget(selectReciterState),
          ),
          SizedBox(
            height: 42,
          ),
          ButtonSecondary(
            label: "Save",
            onTap: () async {
              await ref
                  .read(SelectReciterBottomSheetProvider.notifier)
                  .saveDataReciter(id, nameReciter);
              print("ini ada dibutton");
              print(id);
              print(nameReciter);
              print("-------");
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChangeReciterWidget(
    SelectReciterBottomSheetState state,
  ) {
    print("xxxxxxx");
    print(id);
    print(nameReciter);

    return ListView.builder(
      itemCount: state.listReciter!.length,
      itemBuilder: (context, index) {
        return SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 7,
                child: RadioListTile<dynamic>(
                  value: state.listReciter![index].id,
                  groupValue: id,
                  onChanged: (value) {
                    setState(() {
                      id = value;
                      nameReciter = state.listReciter![index].name;
                      print("haiiii");
                      print(id);
                      print(nameReciter);
                    });
                  },
                  title: Text(state.listReciter![index].name),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.play_circle_filled,
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.brandFair,
                      light: QPColors.brandFair,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
