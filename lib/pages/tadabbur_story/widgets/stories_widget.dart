import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoriesWidget extends StatefulWidget {
  final List<TadabburContentItem> stories;
  final String surahName;
  final int ayahNumber;
  final int nextTadabburId;
  final int previousTadabburId;

  const StoriesWidget({
    required this.surahName,
    required this.ayahNumber,
    required this.nextTadabburId,
    required this.previousTadabburId,
    required this.stories,
    Key? key,
  }) : super(key: key);

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
                          "The Beginning of The Story",
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
                            ? const Border.fromBorderSide(BorderSide(
                                color: QPColors.whiteRoot,
                                width: 1,
                              ))
                            : null,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        height: 4,
                        decoration: const BoxDecoration(
                          color: QPColors.whiteRoot,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
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
            onTapDown: (details) => _onTapDown(details),
            onPanUpdate: (details) => _onPanUpdate(details),
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, i) {
                final currentStory = widget.stories[i];

                return CachedNetworkImage(
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: CircularProgressIndicator(
                      value: progress.progress,
                    ),
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

  void _onTapDown(TapDownDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (_currentIndex + 1 < widget.stories.length) {
          _currentIndex += 1;
        } else {
          _currentIndex = 0;
        }
      });
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
