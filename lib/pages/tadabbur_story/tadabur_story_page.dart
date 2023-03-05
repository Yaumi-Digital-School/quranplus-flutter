import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_story/widgets/stories_widget.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';

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
      body: SafeArea(
        child: StoriesWidget(
          ayahNumber: data.ayahNumber,
          nextTadabburId: data.nextTadabburId,
          previousTadabburId: data.previousTadabburId,
          surahName: "Al-Fatihah",
          stories: data.tadabburContent,
        ),
      ),
    );
  }
}
