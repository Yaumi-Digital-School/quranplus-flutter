import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/location_manual/location_manual_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_themed_colors.dart';

class CitiesWidget extends ConsumerWidget {
  const CitiesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LocationManualState locationManualState = ref.watch(
      locationManualProvider,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: ListView.separated(
        itemCount: locationManualState.cities.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            ref.read(locationManualProvider.notifier).onSelectCity(
              locationManualState.cities[index].id,
              locationManualState.cities[index].label,
              () {
                Navigator.pop(context);
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationManualState.cities[index].city,
                  style: QPTextStyle.getSubHeading4SemiBold(context).copyWith(
                    color: context.qpColors.resolve(
                      context.qpColors.brand100,
                      light: QPColors.blackHeavy,
                    ),
                  ),
                ),
                Text(
                  locationManualState.cities[index].label,
                  style: QPTextStyle.getDescription2Regular(context).copyWith(
                    color: context.qpColors.resolve(
                      context.qpColors.neutral100,
                      dark: QPColors.whiteRoot,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: context.qpColors.resolve(
              context.qpColors.neutral20,
              brown: QPColors.brownModeMassive,
            ),
          );
        },
      ),
    );
  }
}
