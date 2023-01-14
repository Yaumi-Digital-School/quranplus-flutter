import 'package:flutter/material.dart';

class HabitGroupListView extends StatelessWidget {
  final List<dynamic> listGroup;
  const HabitGroupListView({required this.listGroup, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildChildren(),
    );
  }

  List<Widget> _buildChildren() {
    final List<Widget> result = [];
    for (var i in listGroup) {
      result.add(_buildItem(i));
    }

    return result;
  }

  Widget _buildItem(dynamic item) {
    return Text(item);
  }
}
