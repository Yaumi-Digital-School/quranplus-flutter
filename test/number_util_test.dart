// Tests for lib/shared/utils/number_util.dart's formatTwoDigits, which
// zero-pads hour/minute components for adzan-time display (home page adzan
// card, bookmark "time ago" formatting, prayer times service/notifier).

import 'package:flutter_test/flutter_test.dart';
import 'package:qurantafsir_flutter/shared/utils/number_util.dart';

void main() {
  group('formatTwoDigits', () {
    test('single-digit values are zero-padded', () {
      expect(formatTwoDigits(9), '09');
      expect(formatTwoDigits(0), '00');
      expect(formatTwoDigits(5), '05');
    });

    test('two-digit values are left unchanged', () {
      expect(formatTwoDigits(14), '14');
      expect(formatTwoDigits(59), '59');
      expect(formatTwoDigits(10), '10');
    });
  });
}
