import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_story/tadabbur_story_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_story/widgets/stories_widget.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/on_boarding_widget.dart';
import 'package:qurantafsir_flutter/widgets/step_widget.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';

class TadabburStoryPageParams {
  TadabburStoryPageParams({
    required this.tadabburId,
  });

  final int tadabburId;
}

class TadabburStoryPage extends StatelessWidget {
  const TadabburStoryPage({
    required this.params,
    Key? key,
  }) : super(key: key);

  final TadabburStoryPageParams params;

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<TadabburStoryPageStateNotifier,
        TadabburStoryPageState>(
      onStateNotifierReady: (
        TadabburStoryPageStateNotifier notifier,
        WidgetRef ref,
      ) async {
        await notifier.initStateNotifier();
      },
      stateNotifierProvider: StateNotifierProvider<
          TadabburStoryPageStateNotifier, TadabburStoryPageState>((ref) {
        return TadabburStoryPageStateNotifier(
          tadabburApi: ref.read(tadabburApiProvider),
          params: params,
        );
      }),
      builder: (
        _,
        TadabburStoryPageState state,
        TadabburStoryPageStateNotifier notifier,
        WidgetRef ref,
      ) {
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: QPColors.whiteMassive,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: QPColors.whiteMassive,
          body: OnBoardingWidget(
            onBoardingKey: SharedPreferenceService.isAlreadyOnBoardingTadabbur,
            listWidget: _getListStepParams(context),
            child: SafeArea(
              bottom: false,
              child: StoriesWidget(
                ayahNumber: state.contentInfo!.ayahNumber,
                surahName: state.contentInfo!.surahInfo.surahName,
                stories: state.contentInfo!.tadabburContent,
                title: state.contentInfo!.title,
              ),
            ),
          ),
        );
      },
    );
  }

  List<StepParams> _getListStepParams(BuildContext context) {
    return [
      StepParams(
        buttonTitle: "Get Started",
        description: "We’ve made the tadabbur\nprocess more enjoyable",
        direction: StepDirection.column,
        mainWidget: Text(
          "Welcome to Tadabbur!",
          style: QPTextStyle.subHeading1SemiBold.copyWith(color: Colors.white),
        ),
        left: 48,
        bottom: 0,
        right: 48,
        top: 0.4 * MediaQuery.of(context).size.height,
      ),
      StepParams(
        buttonTitle: "Got It",
        description: "This is the ayah and the surah",
        direction: StepDirection.row,
        mainWidget: Image.asset(ImagePath.onBoardingArrowLeft, height: 56),
        left: 28,
        top: 48,
        marginTopMainWidget: 45,
      ),
      StepParams(
        buttonTitle: "Got It",
        description: "Tap on the right side to\nnext story",
        direction: StepDirection.rowReverse,
        mainWidget: Image.asset(ImagePath.onBoardingFingerRight, height: 48),
        right: 28,
        top: 0.4 * MediaQuery.of(context).size.height,
        marginTopMainWidget: 24,
      ),
      StepParams(
        buttonTitle: "Got It",
        description: "Tap on the left side to\nprevious story",
        direction: StepDirection.row,
        mainWidget: Image.asset(ImagePath.onBoardingFingerLeft, height: 48),
        left: 28,
        top: 0.4 * MediaQuery.of(context).size.height,
        marginTopMainWidget: 24,
      ),
      StepParams(
        buttonTitle: "Got It",
        description: "Swipe left to go to the\nnext ayah",
        direction: StepDirection.column,
        mainWidget: Image.asset(ImagePath.onBoardingSwipeLeft, height: 64),
        left: 48,
        bottom: 0,
        right: 48,
        top: 0.4 * MediaQuery.of(context).size.height,
      ),
      StepParams(
        buttonTitle: "Got It",
        description: "Swipe right to go to the\nprevious ayah",
        direction: StepDirection.column,
        mainWidget: Image.asset(ImagePath.onBoardingSwipeRight, height: 64),
        left: 48,
        bottom: 0,
        right: 48,
        top: 0.4 * MediaQuery.of(context).size.height,
      ),
    ];
  }
}
