import 'package:flutter/material.dart';

class BasmalahWidget extends StatelessWidget {
  const BasmalahWidget({
    super.key,
    this.isInFullPage = false,
    required this.orientation,
  });

  final bool isInFullPage;
  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    if (isInFullPage) {
      return Image.asset(
        'images/bismillah_v2.png',
        width: orientation == Orientation.landscape ? 300 : 170,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return Image.asset(
      'images/bismillah_v2.png',
      color: Theme.of(context).colorScheme.primary,
      width: 165,
      height: 80,
      fit: BoxFit.contain,
    );
  }
}
