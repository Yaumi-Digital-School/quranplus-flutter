import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/core/models/theme_option_color_param.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/theme_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/adaptive_theme_dialog.dart';
import 'package:qurantafsir_flutter/widgets/theme_box_option_widget.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/widgets/utils/general_dialog.dart';

class ChangeThemeBottomSheet extends ConsumerStatefulWidget {
  const ChangeThemeBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<ChangeThemeBottomSheet> createState() =>
      _ChangeThemeBottomSheetState();
}

class _ChangeThemeBottomSheetState
    extends ConsumerState<ChangeThemeBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final ThemeStateNotifier themeStateNotifier =
        ref.read(themeProvider.notifier);

    final QPThemeMode stateTheme = ref.read(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select the theme mode",
          style: QPTextStyle.getSubHeading2SemiBold(context),
        ),
        const SizedBox(height: 8),
        Text(
          "Select available mode to read and explore our app",
          style: QPTextStyle.getBody3Regular(context),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ThemeBoxOptionWidget(
                theme: QPThemeMode.light.label,
                colorParam: ThemeOptionColorParam(
                  firstColor: QPColors.whiteSoft,
                  secondColor: QPColors.whiteMassive,
                  thirdColor: QPColors.whiteRoot,
                ),
                isSelected: stateTheme == QPThemeMode.light,
                onTap: () async => _setTheme(
                  QPThemeMode.light,
                  themeStateNotifier,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ThemeBoxOptionWidget(
                theme: QPThemeMode.dark.label,
                colorParam: ThemeOptionColorParam(
                  firstColor: QPColors.darkModeHeavy,
                  secondColor: QPColors.blackFair,
                  thirdColor: QPColors.darkModeFair,
                ),
                isSelected: stateTheme == QPThemeMode.dark,
                onTap: () async => _setTheme(
                  QPThemeMode.dark,
                  themeStateNotifier,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ThemeBoxOptionWidget(
                theme: QPThemeMode.brown.label,
                colorParam: ThemeOptionColorParam(
                  firstColor: QPColors.brownModeRoot,
                  secondColor: QPColors.whiteMassive,
                  thirdColor: QPColors.brownModeFair,
                ),
                isSelected: stateTheme == QPThemeMode.brown,
                onTap: () async => _setTheme(
                  QPThemeMode.brown,
                  themeStateNotifier,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _setTheme(
    QPThemeMode mode,
    ThemeStateNotifier themeNotifier,
  ) async {
    showQPGeneralDialog(
      context: context,
      isBarrierDismissable: false,
      builder: (BuildContext context) {
        return AdaptiveThemeDialog(
          contentPadding: const EdgeInsets.fromLTRB(
            24.0,
            20.0,
            24.0,
            24.0,
          ),
          borderRadiusValue: 19,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                height: 24,
              ),
              Text(
                'Applying theme...',
                style: QPTextStyle.getSubHeading2Regular(context),
              ),
            ],
          ),
        );
      },
    );
    await Future.delayed(const Duration(seconds: 1), () {
      themeNotifier.setMode(mode);
    });

    await Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }
}
