import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';

class PrayerCalculationSelector extends ConsumerWidget {
  const PrayerCalculationSelector({super.key});

  static const List<String> _methods = [
    'singapore',
    'muslimworldleague',
    'egyptian',
    'ummAlqura',
  ];

  static const List<String> _madhabs = ['shafi', 'hanafi'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculationMethod = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(madhubProvider);
    final notifier = ref.read(prayerTimeProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: calculationMethod,
            items: _methods
                .map(
                  (method) => DropdownMenuItem(
                    value: method,
                    child: Text(
                      _formatMethodName(method),
                      style: QPTextStyle.getDescription2Regular(context),
                    ),
                  ),
                )
                .toList(),
            onChanged: (newMethod) {
              if (newMethod != null) {
                ref.read(calculationMethodProvider.notifier).set(newMethod);
                notifier.updatePrayerTimes(newMethod, madhab);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: madhab,
            items: _madhabs
                .map(
                  (school) => DropdownMenuItem(
                    value: school,
                    child: Text(
                      _formatMadhabName(school),
                      style: QPTextStyle.getDescription2Regular(context),
                    ),
                  ),
                )
                .toList(),
            onChanged: (newSchool) {
              if (newSchool != null) {
                ref.read(madhubProvider.notifier).set(newSchool);
                notifier.updatePrayerTimes(calculationMethod, newSchool);
              }
            },
          ),
        ),
      ],
    );
  }

  static String _formatMethodName(String method) {
    switch (method) {
      case 'singapore':
        return 'Singapore';
      case 'muslimworldleague':
        return 'Muslim World League';
      case 'egyptian':
        return 'Egyptian';
      case 'ummAlqura':
        return 'Umm Al-Qura';
      default:
        return method;
    }
  }

  static String _formatMadhabName(String school) {
    return school == 'shafi' ? "Syafi'i" : 'Hanafi';
  }
}
