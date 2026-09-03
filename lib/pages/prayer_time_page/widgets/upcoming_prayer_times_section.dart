import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/widgets/prayer_time_row.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

/// Number of years ahead the by-date calendar allows selecting.
const int _calendarYearsAhead = 5;

/// Shows tomorrow's prayer times (rendered exactly like the today card via
/// [PrayerTimeRow]) plus a "Check another date" entry point that opens a bottom
/// sheet with an inline calendar and live times for any picked date. Reacts to
/// location changes by watching `prayerTimeProvider`; hidden entirely when no
/// location is available (mirrors the today card's empty state).
class UpcomingPrayerTimesSection extends ConsumerWidget {
  const UpcomingPrayerTimesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching today's prayerTimes makes this section rebuild on location
    // changes (a new PrayerTimes instance is produced each time).
    ref.watch(prayerTimeProvider.select((PrayerTimeState s) => s.prayerTimes));
    final PrayerTimesService service = ref.watch(prayerTimesService);

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime tomorrow = today.add(const Duration(days: 1));

    final PrayerTimes? tomorrowTimes = service.getPrayerTimesByDate(
      date: tomorrow,
    );
    if (tomorrowTimes == null) {
      // No location set -> hide the whole section (mirrors the today card).
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _UpcomingDayCard(
          title: 'Tomorrow, ${DateFormat('d MMM yyyy').format(tomorrow)}',
          times: tomorrowTimes,
        ),
        const SizedBox(height: 8),
        _CheckAnotherDateTrigger(
          onTap: () => _openByDateSheet(context, service, today),
        ),
      ],
    );
  }

  void _openByDateSheet(
    BuildContext context,
    PrayerTimesService service,
    DateTime today,
  ) {
    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: _PrayerTimesByDateSheet(
        service: service,
        firstDate: today,
        lastDate: DateTime(
          today.year + _calendarYearsAhead,
          today.month,
          today.day,
        ),
        initialDate: today,
      ),
    );
  }
}

Color _sectionTextColor(BuildContext context) {
  return QPColors.getColorBasedTheme(
    dark: QPColors.whiteRoot,
    light: QPColors.blackMassive,
    brown: QPColors.brownModeMassive,
    context: context,
  );
}

/// A theme scoped to the inline calendar so the selected date and day numbers
/// stay legible in every app theme. The global dark `ColorScheme` sets `primary`
/// to a near-white and keeps a dark `onSurface`/default white `onPrimary`, which
/// renders the selection (white-on-near-white) and day text (dark-on-dark)
/// invisible. Here the selection is a brand-green chip with white text, and day
/// text is high-contrast against the sheet background.
ThemeData _calendarThemeData(BuildContext context) {
  final ThemeData base = Theme.of(context);
  final QPThemeMode mode = QPThemeData.getThemeModeBasedContext(context);

  late final Color dayText;
  late final Color surface;
  switch (mode) {
    case QPThemeMode.dark:
      dayText = QPColors.whiteFair;
      surface = QPColors.darkModeMassive;
      break;
    case QPThemeMode.brown:
      dayText = QPColors.brownModeMassive;
      surface = QPColors.brownModeRoot;
      break;
    case QPThemeMode.light:
      dayText = QPColors.blackMassive;
      surface = QPColors.whiteFair;
      break;
  }

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: QPColors.brandHeavy,
      onPrimary: QPColors.whiteMassive,
      onSurface: dayText,
      onSurfaceVariant: dayText,
      surface: surface,
    ),
  );
}

class _UpcomingDayCard extends StatelessWidget {
  const _UpcomingDayCard({required this.title, required this.times});

  final String title;
  final PrayerTimes times;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: QPTextStyle.getBody2SemiBold(
                context,
              ).copyWith(color: _sectionTextColor(context)),
            ),
            const SizedBox(height: 12),
            PrayerTimeRow(prayerTimes: times),
          ],
        ),
      ),
    );
  }
}

class _CheckAnotherDateTrigger extends StatelessWidget {
  const _CheckAnotherDateTrigger({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor = _sectionTextColor(context);

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.calendar_today, size: 18, color: textColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Check another date',
                  style: QPTextStyle.getBody2SemiBold(
                    context,
                  ).copyWith(color: textColor),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom-sheet content: a title, the selected date, an inline calendar, and the
/// prayer times for the selected date (via [PrayerTimeRow]) that update live as
/// the date changes.
class _PrayerTimesByDateSheet extends StatefulWidget {
  const _PrayerTimesByDateSheet({
    required this.service,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
  });

  final PrayerTimesService service;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;

  @override
  State<_PrayerTimesByDateSheet> createState() =>
      _PrayerTimesByDateSheetState();
}

class _PrayerTimesByDateSheetState extends State<_PrayerTimesByDateSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = _sectionTextColor(context);
    final PrayerTimes? times = widget.service.getPrayerTimesByDate(
      date: _selectedDate,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Prayer Times',
            style: QPTextStyle.getSubHeading2SemiBold(context),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, d MMM yyyy').format(_selectedDate),
            style: QPTextStyle.getDescription2Medium(context).copyWith(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteRoot,
                light: QPColors.blackFair,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Theme(
            data: _calendarThemeData(context),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: (DateTime date) {
                setState(() => _selectedDate = date);
              },
            ),
          ),
          const SizedBox(height: 8),
          if (times != null)
            PrayerTimeRow(prayerTimes: times)
          else
            Text(
              'No location set.',
              style: QPTextStyle.getBaseTextStyle(
                context,
              ).copyWith(color: textColor),
            ),
        ],
      ),
    );
  }
}
