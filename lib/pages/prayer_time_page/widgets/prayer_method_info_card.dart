import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';

class PrayerMethodInfoCard extends ConsumerWidget {
  const PrayerMethodInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculationMethod = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(madhubProvider);

    final methodDescription = _getMethodDescription(calculationMethod);
    final madhabText = madhab == 'shafi' ? "Syafi'i" : 'Hanafi';

    return SizedBox(
      width: double.infinity,
      child: Text(
        'Metode: $methodDescription · Mazhab $madhabText',
        style: QPTextStyle.getDescription2Medium(context),
        textAlign: TextAlign.left,
      ),
    );
  }

  static String _getMethodDescription(String method) {
    switch (method) {
      case 'singapore':
        return 'Singapore region (Indonesia, Malaysia, Singapore)';
      case 'muslimworldleague':
        return 'Muslim World League';
      case 'egyptian':
        return 'Egyptian General Authority of Survey';
      case 'ummAlqura':
        return 'Umm Al-Qura University (Saudi Arabia)';
      default:
        return method;
    }
  }
}
