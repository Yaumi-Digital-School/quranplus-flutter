import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_story/widgets/stories_widget.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/on_boarding_widget.dart';
import 'package:qurantafsir_flutter/widgets/step_widget.dart';

var data = TadabburContentResponse(
  ayahNumber: 1,
  nextTadabburId: 2,
  previousTadabburId: 0,
  surah: 1,
  tadabburContent: [
    TadabburContentItem(
      content:
          "https://images.unsplash.com/photo-1534103362078-d07e750bd0c4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80",
      contentType: "",
    ),
    TadabburContentItem(
      content:
          "https://images.unsplash.com/photo-1531694611353-d4758f86fa6d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=564&q=80",
      contentType: "",
    ),
    TadabburContentItem(
      content: "https://media2.giphy.com/media/M8PxVICV5KlezP1pGE/giphy.gif",
      contentType: "",
    ),
  ],
  title: "The Begining of The Story",
);

class TadabburStoryPage extends StatelessWidget {
  const TadabburStoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnBoardingWidget(
        onBoardingKey: SharedPreferenceService.isAlreadyOnBoardingTadabbur,
        listWidget: _getListStepParams(context),
        child: SafeArea(
          child: StoriesWidget(
            ayahNumber: data.ayahNumber,
            nextTadabburId: data.nextTadabburId,
            previousTadabburId: data.previousTadabburId,
            surahName: "Al-Fatihah",
            stories: data.tadabburContent,
          ),
        ),
      ),
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
