import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../shared/constants/theme.dart';

class HabitPage extends StatelessWidget {
  const HabitPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54.0),
        child: AppBar(
          elevation: 0.7,
          foregroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            'Habit',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: backgroundColor,
        ),
      ),
      body: const Center(),
    );
  }
}
