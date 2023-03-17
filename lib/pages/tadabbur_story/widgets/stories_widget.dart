import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoriesWidget extends StatefulWidget {
  const StoriesWidget({
    required this.surahName,
    required this.ayahNumber,
    required this.stories,
    required this.title,
    this.previousTadabburId,
    this.nextTadabburId,
    Key? key,
  }) : super(key: key);

  final List<TadabburContentItem> stories;
  final String surahName;
  final int ayahNumber;
  final String title;
  final int? previousTadabburId;
  final int? nextTadabburId;

  @override
  State<StoriesWidget> createState() => _StoriesWidgetState();
}

class _StoriesWidgetState extends State<StoriesWidget> {
  PageController? _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, right: 24, left: 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Ayah ${widget.ayahNumber}",
                              style: QPTextStyle.button3Medium
                                  .copyWith(color: QPColors.blackSoft),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: QPColors.blackSoft,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.surahName,
                              style: QPTextStyle.button3Medium
                                  .copyWith(color: QPColors.blackSoft),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.title,
                          style: QPTextStyle.button1SemiBold.copyWith(
                            color: QPColors.blackHeavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      color: QPColors.blackFair,
                      size: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.stories.length,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 1,
                        right: index == widget.stories.length - 1 ? 0 : 1,
                      ),
                      decoration: BoxDecoration(
                        border: index == _currentIndex
                            ? const Border.fromBorderSide(
                                BorderSide(
                                  color: QPColors.whiteRoot,
                                  width: 1,
                                ),
                              )
                            : null,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= _currentIndex
                              ? QPColors.brandFair
                              : QPColors.whiteRoot,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTapUp: (details) => _onTapDown(details),
            onPanUpdate: (details) => _onPanUpdate(details),
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, i) {
                final currentStory = widget.stories[i];

                return CachedNetworkImage(
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) =>
                      const Center(
                    child: CircularProgressIndicator(),
                  ),
                  imageUrl: currentStory.content,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onTapDown(TapUpDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    final bool isTapLeft = dx < screenWidth / 3;
    final bool isTapRight = dx > 2 * screenWidth / 3;

    if (isTapLeft) {
      if (_currentIndex == 0) {
        if (widget.previousTadabburId == null) {
          Navigator.pop(context);

          return;
        }
      }

      if (_currentIndex - 1 >= 0) {
        setState(() {
          _currentIndex -= 1;
        });
      }
    } else if (isTapRight) {
      if (_currentIndex + 1 == widget.stories.length) {
        if (widget.nextTadabburId == null) {
          Navigator.pop(context);

          return;
        }
      }

      if (_currentIndex + 1 < widget.stories.length) {
        setState(() {
          _currentIndex += 1;
        });
      }
    }

    _pageController?.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Swiping in previous direction.
    if (details.delta.dx > 0) {
      print("previous");
    }

    // Swiping in next direction.
    if (details.delta.dx < 0) {
      print("next");
    }
  }
}
