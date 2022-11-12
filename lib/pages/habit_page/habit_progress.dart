import 'package:flutter/material.dart';

import '../../shared/constants/theme.dart';
import '../../widgets/daily_progress_tracker.dart';

class HabitProgress extends StatelessWidget {
  const HabitProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 40,
            ),
            Text(
              "Start your Reading Habit",
              style: TextStyle(
                  fontSize: 16, color: neutral900, fontWeight: semiBold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Now you can update and set your personal reading progress and target",
              style: TextStyle(fontSize: 14, color: neutral600),
            ),
            const SizedBox(
              height: 24,
            ),
            Card(
              color: Colors.white,
              elevation: 1.2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    DailyProgressTracker(target: 2, dailyProgress: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
