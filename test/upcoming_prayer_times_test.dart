// Widget tests for the "Tomorrow + check another date" section.
//
// The section is pumped in isolation with `prayerTimesService` and
// `sharedPreferenceServiceProvider` overridden by real instances seeded with
// Jakarta coordinates. Covers: the Tomorrow card (rendered via the shared
// PrayerTimeRow, icons+labels+times laid out horizontally), the "Check another
// date" trigger, the no-location hidden state, PrayerTimeRow's parameterized
// mode, and the by-date bottom sheet (inline calendar + live times).

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/widgets/prayer_time_row.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/widgets/upcoming_prayer_times_section.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> labels = <String>[
  'Fajr',
  'Dzuhur',
  'Ashr',
  'Magrib',
  'Isya',
];

final RegExp timeRegex = RegExp(r'^\d{2}:\d{2}$');

class Seed {
  Seed(this.sp, this.service);

  final SharedPreferenceService sp;
  final PrayerTimesService service;
}

Future<Seed> makeSeed({required bool withLocation}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferenceService sp = SharedPreferenceService();
  await sp.init();
  if (withLocation) {
    await sp.setLocation(-6.2, 106.8);
    await sp.setCityName('Jakarta');
  }
  final PrayerTimesService service = PrayerTimesService(
    notificationService: NotificationService(),
    sharedPreferenceService: sp,
  );
  service.init();
  return Seed(sp, service);
}

Future<void> pumpSection(WidgetTester tester, Seed seed) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferenceServiceProvider.overrideWithValue(seed.sp),
        prayerTimesService.overrideWithValue(seed.service),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: UpcomingPrayerTimesSection()),
        ),
      ),
    ),
  );
  await tester.pump();
}

PrayerTimes buildJakartaPrayerTimes(DateTime localDay) {
  final CalculationParameters params = CalculationMethodParameters.singapore();
  params.madhab = Madhab.shafi;
  return PrayerTimes(
    coordinates: const Coordinates(-6.2, 106.8),
    date: anchorDateForPrayerCalc(localDay),
    calculationParameters: params,
  );
}

int countTimeTexts(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .where((Text t) => t.data != null && timeRegex.hasMatch(t.data!))
      .length;
}

void main() {
  testWidgets(
    'Tomorrow card shows "Tomorrow, <date>", five labels and HH:mm times',
    (WidgetTester tester) async {
      final Seed seed = await makeSeed(withLocation: true);
      await pumpSection(tester, seed);

      final DateTime now = DateTime.now();
      final DateTime tomorrow = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));
      final String title =
          'Tomorrow, ${DateFormat('d MMM yyyy').format(tomorrow)}';

      expect(find.text(title), findsOneWidget);
      // One PrayerTimeRow (the Tomorrow card); the trigger has none.
      expect(find.byType(PrayerTimeRow), findsOneWidget);
      for (final String label in labels) {
        expect(find.text(label), findsOneWidget);
      }
      expect(countTimeTexts(tester), 5);
    },
  );

  testWidgets('labels are laid out horizontally in fajr -> isya order (LTR)', (
    WidgetTester tester,
  ) async {
    final Seed seed = await makeSeed(withLocation: true);
    await pumpSection(tester, seed);

    double dx(String label) => tester.getTopLeft(find.text(label)).dx;

    expect(dx('Fajr'), lessThan(dx('Dzuhur')));
    expect(dx('Dzuhur'), lessThan(dx('Ashr')));
    expect(dx('Ashr'), lessThan(dx('Magrib')));
    expect(dx('Magrib'), lessThan(dx('Isya')));
  });

  testWidgets('shows the "Check another date" trigger when located', (
    WidgetTester tester,
  ) async {
    final Seed seed = await makeSeed(withLocation: true);
    await pumpSection(tester, seed);

    expect(find.text('Check another date'), findsOneWidget);
  });

  testWidgets('hides the Tomorrow card and trigger when no location', (
    WidgetTester tester,
  ) async {
    final Seed seed = await makeSeed(withLocation: false);
    await pumpSection(tester, seed);

    expect(find.byType(PrayerTimeRow), findsNothing);
    expect(find.text('Check another date'), findsNothing);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets(
    'PrayerTimeRow renders from an explicit PrayerTimes without the provider',
    (WidgetTester tester) async {
      final PrayerTimes times = buildJakartaPrayerTimes(DateTime(2026, 9, 4));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PrayerTimeRow(prayerTimes: times)),
          ),
        ),
      );
      await tester.pump();

      for (final String label in labels) {
        expect(find.text(label), findsOneWidget);
      }
      expect(countTimeTexts(tester), 5);
    },
  );

  testWidgets(
    'trigger opens a bottom sheet with the calendar, date line and times',
    (WidgetTester tester) async {
      final Seed seed = await makeSeed(withLocation: true);
      await pumpSection(tester, seed);

      await tester.tap(find.text('Check another date'));
      await tester.pumpAndSettle();

      // Scope assertions to the sheet (the Tomorrow card stays in the tree
      // behind the modal barrier).
      final Finder sheet = find.byType(BaseWidgetBottomSheet);
      expect(sheet, findsOneWidget);

      // Sheet content: title, inline calendar, and a PrayerTimeRow.
      expect(
        find.descendant(of: sheet, matching: find.text('Prayer Times')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.byType(CalendarDatePicker)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.byType(PrayerTimeRow)),
        findsOneWidget,
      );

      // Opens on today's date line.
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(DateFormat('EEEE, d MMM yyyy').format(today)),
        ),
        findsOneWidget,
      );

      // Times for the selected date, inside the sheet.
      for (final String label in labels) {
        expect(
          find.descendant(of: sheet, matching: find.text(label)),
          findsOneWidget,
        );
      }
      final int sheetTimeTexts = tester
          .widgetList<Text>(
            find.descendant(of: sheet, matching: find.byType(Text)),
          )
          .where((Text t) => t.data != null && timeRegex.hasMatch(t.data!))
          .length;
      expect(sheetTimeTexts, 5);
    },
  );

  testWidgets('picking another date in the sheet updates the date line live', (
    WidgetTester tester,
  ) async {
    final Seed seed = await makeSeed(withLocation: true);
    await pumpSection(tester, seed);

    await tester.tap(find.text('Check another date'));
    await tester.pumpAndSettle();

    // Navigate to next month and select the 1st — always after `today` and
    // within the 5-year range, avoiding month-boundary fragility.
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    final DateTime now = DateTime.now();
    final DateTime nextMonthFirst = DateTime(now.year, now.month + 1, 1);
    expect(
      find.text(DateFormat('EEEE, d MMM yyyy').format(nextMonthFirst)),
      findsOneWidget,
    );
  });
}
