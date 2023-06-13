import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoriesWidget extends StatefulWidget {
  const StoriesWidget({
    required this.contentInfo,
    required this.onOpenNextTadabbur,
    required this.onOpenPrevTadabbur,
    required this.updateLatestReadStoryIndex,
    this.lastReadStoryIndex,
    this.onClose,
    Key? key,
  }) : super(key: key);

  final VoidCallback onOpenPrevTadabbur;
  final VoidCallback onOpenNextTadabbur;
  final VoidCallback? onClose;
  final int? lastReadStoryIndex;
  final Function(int) updateLatestReadStoryIndex;
  final TadabburContentReadingInfo contentInfo;

  @override
  State<StoriesWidget> createState() => _StoriesWidgetState();
}

class _StoriesWidgetState extends State<StoriesWidget> {
  late PageController _pageController;
  late TadabburContentResponse content;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    if (widget.lastReadStoryIndex != null) {
      _currentIndex = widget.lastReadStoryIndex!;
    }

    content = widget.contentInfo.content;

    _pageController = PageController(
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 12,
              right: 24,
              left: 24,
            ),
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
                                "Ayah ${content.ayahNumber}",
                                style: QPTextStyle.getButton3Medium(context)
                                    .copyWith(
                                  color: QPColors.blackSoft,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: QPColors.whiteRoot,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                content.surahInfo?.surahName ?? '',
                                style: QPTextStyle.getButton3Medium(
                                  context,
                                ).copyWith(
                                  color: QPColors.blackSoft,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            content.title ?? '',
                            style: QPTextStyle.getButton1SemiBold(context)
                                .copyWith(
                              color: QPColors.blackHeavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        if (widget.onClose != null) {
                          widget.onClose!();
                        }

                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.close,
                        color: QPColors.blackFair,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    content.tadabburContent?.length ?? 0,
                    (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          left: index == 0 ? 0 : 1,
                          right: index == content.tadabburContent!.length - 1
                              ? 0
                              : 1,
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
                            color: index < _currentIndex
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
              onTapUp: (details) => _onTapUp(details),
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: content.tadabburContent?.length ?? 0,
                itemBuilder: (context, i) {
                  final currentStory = content.tadabburContent![i];

                  return ListView(
                    children: [
                      CachedNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        progressIndicatorBuilder: (context, url, progress) =>
                            const Center(
                          child: CircularProgressIndicator(),
                        ),
                        imageUrl: currentStory.content,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTapUp(TapUpDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    final bool isTapLeft = dx < screenWidth / 3;
    final bool isTapRight = dx > 2 * screenWidth / 3;

    if (isTapLeft) {
      if (_currentIndex == 0) {
        if (content.previousTadabburId == null) {
          Navigator.pop(context);

          return;
        }

        widget.onOpenPrevTadabbur();

        return;
      }

      if (_currentIndex - 1 >= 0) {
        setState(() {
          _currentIndex -= 1;
        });
      }
    } else if (isTapRight) {
      if (_currentIndex + 1 == content.tadabburContent?.length) {
        if (content.nextTadabburId == null) {
          Navigator.pop(context);

          return;
        }

        widget.onOpenNextTadabbur();

        return;
      }

      if (_currentIndex + 1 < (content.tadabburContent?.length ?? 0)) {
        setState(() {
          _currentIndex += 1;
        });
      }
    }

    widget.updateLatestReadStoryIndex(_currentIndex);

    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeInOut,
    );
  }
}
