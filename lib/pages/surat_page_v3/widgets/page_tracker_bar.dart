import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class PageTrackerBar extends ConsumerWidget {
  const PageTrackerBar({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitState = ref.watch(suratPageHabitProvider);
    final habitNotifier = ref.read(suratPageHabitProvider.notifier);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              offset: Offset(1.0, 2.0),
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
          ],
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stop_circle_outlined, size: 14.0, color: red300),
            const SizedBox(width: 9),
            Text(
              'Stop Tracking (${habitState.recordedPagesAsRead}/${habitNotifier.habitDailyTarget} Page)',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
