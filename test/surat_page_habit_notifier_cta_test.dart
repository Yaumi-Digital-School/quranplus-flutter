// Regression test for: in full-page mode, swiping to the next/previous page
// must NOT make the minimized audio player appear. The player may only appear
// when ayah audio is actually played.
//
// The buggy wiring lives in the inline onTapToggleCTA / onPageChanged closures
// in surat_page_v3.dart's FullPagePagesView. Those closures have no cheap test
// seam (exercising them requires pumping the full SuratPageV3 with its async
// init / DB / audio dependencies). The closest correct seam is the notifier
// behavior the closures now delegate to:
//   - onTapToggleCTA -> habitNotifier.toggleReadCTAVisible()
//   - onPageChanged  -> habitNotifier.setIsOnReadCTAVisible(true)
// Neither may touch showMinimizedAudioPlayer. These notifier-level assertions
// verify exactly that.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_habit_state.dart';

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test(
    'toggleReadCTAVisible flips isOnReadCTAVisible true -> false -> true',
    () {
      final container = makeContainer();
      final notifier = container.read(suratPageHabitProvider.notifier);

      expect(container.read(suratPageHabitProvider).isOnReadCTAVisible, isTrue);

      notifier.toggleReadCTAVisible();
      expect(
        container.read(suratPageHabitProvider).isOnReadCTAVisible,
        isFalse,
      );

      notifier.toggleReadCTAVisible();
      expect(container.read(suratPageHabitProvider).isOnReadCTAVisible, isTrue);
    },
  );

  test(
    'page-change path setIsOnReadCTAVisible(true) never shows the mini player',
    () {
      final container = makeContainer();
      final notifier = container.read(suratPageHabitProvider.notifier);

      expect(
        container.read(suratPageHabitProvider).showMinimizedAudioPlayer,
        isFalse,
      );

      // Simulate the CTA being hidden first (e.g. by a scroll), then a swipe.
      notifier.setIsOnReadCTAVisible(false);
      expect(
        container.read(suratPageHabitProvider).showMinimizedAudioPlayer,
        isFalse,
      );

      // This is exactly what the full-page onPageChanged now calls on a swipe.
      notifier.setIsOnReadCTAVisible(true);
      expect(container.read(suratPageHabitProvider).isOnReadCTAVisible, isTrue);
      expect(
        container.read(suratPageHabitProvider).showMinimizedAudioPlayer,
        isFalse,
      );
    },
  );

  test('setIsOnReadCTAVisible with an unchanged value does not emit', () {
    final container = makeContainer();
    final notifier = container.read(suratPageHabitProvider.notifier);

    // Default value is already true.
    expect(container.read(suratPageHabitProvider).isOnReadCTAVisible, isTrue);

    int emissions = 0;
    container.listen<SuratPageHabitState>(
      suratPageHabitProvider,
      (previous, next) => emissions++,
    );

    notifier.setIsOnReadCTAVisible(true); // no-op: value unchanged
    expect(emissions, 0);
  });
}
