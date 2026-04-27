import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/location_manual/location_manual_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/location_manual/widgets/cities_widget.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

import 'widgets/cities_not_found_widget.dart';

class LocationManualPage extends ConsumerWidget {
  const LocationManualPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LocationManualState locationManualState =
        ref.watch(locationManualProvider);

    return Scaffold(
      body: Stack(
        children: [
          if (locationManualState.isLoading)
            const Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.only(
              right: 24,
              left: 24,
              top: 32,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Location",
                    style: QPTextStyle.getSubHeading1SemiBold(context),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextField(
                    style: QPTextStyle.getSubHeading4Regular(context),
                    onChanged:
                        ref.read(locationManualProvider.notifier).onChanged,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_on_sharp,
                        color: QPColors.brandFair,
                        size: 24,
                      ),
                      filled: true,
                      fillColor: QPColors.getColorBasedTheme(
                        dark: QPColors.darkModeHeavy,
                        light: QPColors.whiteMassive,
                        brown: QPColors.brownModeFair,
                        context: context,
                      ),
                      isDense: true,
                      hintText: "Type your city here",
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: QPColors.brownModeHeavy,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: QPColors.brownModeHeavy,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: QPColors.brownModeHeavy,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                  if (locationManualState.cities.isNotEmpty)
                    const Flexible(child: CitiesWidget()),
                  if (!locationManualState.isLoading &&
                      !locationManualState.isQueryEmpty &&
                      locationManualState.cities.isEmpty)
                    const CitiesNotFoundWidget(),
                  if (locationManualState.cities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 260,
                          child: Text(
                            "Selecting a location manually, disables your Auto-detect Location. You may enable it again in Settings.",
                            textAlign: TextAlign.center,
                            style: QPTextStyle.getDescription2Regular(context),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
