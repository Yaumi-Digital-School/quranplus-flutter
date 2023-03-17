import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/step_widget.dart';

class OnBoardingWidget extends StatefulWidget {
  final Widget child;
  final String onBoardingKey;
  final List<StepParams> listWidget;
  const OnBoardingWidget({
    required this.onBoardingKey,
    required this.child,
    required this.listWidget,
    Key? key,
  }) : super(key: key);

  @override
  State<OnBoardingWidget> createState() => _OnBoardingWidgetState();
}

class _OnBoardingWidgetState extends State<OnBoardingWidget> {
  bool isVisible = false;
  int step = 0;
  final sharedPreferences = SharedPreferenceService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initSharedPreferences();
    });
  }

  void initSharedPreferences() async {
    await sharedPreferences.init();
    setState(() {
      isVisible =
          !sharedPreferences.getIsAlreadyOnBoarding(widget.onBoardingKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          widget.child,
          if (isVisible)
            Positioned(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          if (isVisible && step < widget.listWidget.length)
            Positioned(
              top: widget.listWidget[step].top,
              right: widget.listWidget[step].right,
              left: widget.listWidget[step].left,
              bottom: widget.listWidget[step].bottom,
              child: SizedBox(
                width: 268,
                height: 500,
                child: StepWidget(
                  onTapNextButton: () {
                    if (step + 1 == widget.listWidget.length) {
                      setState(() {
                        isVisible = false;
                      });
                      sharedPreferences
                          .setAlreadyOnBoarding(widget.onBoardingKey);

                      return;
                    }

                    setState(() {
                      step = step + 1;
                    });
                  },
                  stepParams: widget.listWidget[step],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
