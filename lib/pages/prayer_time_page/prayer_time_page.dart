import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';

import '../../shared/constants/qp_colors.dart';
import '../../shared/constants/qp_text_style.dart';
import '../../shared/constants/route_paths.dart';
import '../../shared/core/providers.dart';
import 'prayer_time_page_state.dart';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({
    Key? key,
  }) : super(key: key);

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage> {
  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<PrayerTimeStateNotifier, PrayerTimePageState>(
      onStateNotifierReady: (
        PrayerTimeStateNotifier notifier,
        WidgetRef ref,
      ) async {
        await notifier.initStateNotifier();
      },
      stateNotifierProvider:
          StateNotifierProvider<PrayerTimeStateNotifier, PrayerTimePageState>(
              (ref) {
        return PrayerTimeStateNotifier();
      }),
      builder: (
        _,
        PrayerTimePageState state,
        PrayerTimeStateNotifier notifier,
        WidgetRef ref,
      ) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      child: Text(
                        'Skip',
                        style: QPTextStyle.subHeading4SemiBold.copyWith(
                          color: QPColors.brandFair,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: QPColors.background,
                        onPrimary: QPColors.brandFair,
                        visualDensity: VisualDensity.compact,
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: QPColors.brandFair, width: 1),
                        ),
                      ),
                      onPressed: () {
                        // Add your button's onTap logic here
                        Navigator.of(context).pushReplacementNamed(
                            RoutePaths.routeNotificationSetting);
                      },
                    ),
                  ),
                  Image.asset(
                    ImagePath.logoQuranPlusPotrait,
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(height: 36),
                  Text(
                    'Quran Plus needs your location to show you prayer time in your region.',
                    style: QPTextStyle.subHeading1SemiBold.copyWith(
                      color: QPColors.blackMassive,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Image.asset(
                    'images/img_prayer.png',
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity, // match parent width
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          children: [
                            Text(
                              'Fajr',
                              style: QPTextStyle.button2SemiBold.copyWith(
                                color: QPColors.blackMassive,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              state.fajr,
                              style: QPTextStyle.button2SemiBold.copyWith(
                                color: QPColors.blackMassive,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Dhuhr',
                              style: QPTextStyle.button2SemiBold.copyWith(
                                color: QPColors.blackMassive,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              state.dhuhr,
                              style: QPTextStyle.button2SemiBold.copyWith(
                                color: QPColors.blackMassive,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Asr',
                              style: QPTextStyle.button2SemiBold.copyWith(
                                color: QPColors.blackMassive,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              state.ashr,
                              style: QPTextStyle.button2SemiBold.copyWith(
                                color: QPColors.blackMassive,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Maghrib',
                              style: QPTextStyle.button2SemiBold.copyWith(
                                color: QPColors.blackMassive,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              state.maghrib,
                              style: QPTextStyle.button2SemiBold.copyWith(
                                color: QPColors.blackMassive,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Isha',
                              style: QPTextStyle.button2SemiBold.copyWith(
                                color: QPColors.blackMassive,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              state.isha,
                              style: QPTextStyle.button2SemiBold.copyWith(
                                color: QPColors.blackMassive,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search, color: QPColors.whiteFair),
                            SizedBox(width: 8),
                            Text(
                              'Search My Location Manually',
                              style: QPTextStyle.subHeading4SemiBold.copyWith(
                                color: QPColors.whiteFair,
                              ),
                            ),
                          ],
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: QPColors.brandFair,
                        onPrimary: QPColors.background,
                        visualDensity: VisualDensity.compact,
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: QPColors.brandFair, width: 1),
                        ),
                      ),
                      onPressed: () {
                        // Add your button's onTap logic here
                        _showBottomSheet(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or',
                            style: QPTextStyle.subHeading4SemiBold.copyWith(
                              color: QPColors.blackSoft,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, color: QPColors.brandFair),
                            SizedBox(width: 8),
                            Text(
                              'Get My Location',
                              style: QPTextStyle.subHeading4SemiBold.copyWith(
                                color: QPColors.brandFair,
                              ),
                            ),
                          ],
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: QPColors.background,
                        onPrimary: Colors.transparent,
                        visualDensity: VisualDensity.compact,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side:
                              BorderSide(color: QPColors.background, width: 1),
                        ),
                      ),
                      onPressed: () {
                        // Add your button's onTap logic here
                        notifier.getPrayerTimes();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            kToolbarHeight,
        decoration: BoxDecoration(
          color: QPColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Location',
                      style: QPTextStyle.subHeading2SemiBold.copyWith(
                        color: QPColors.blackMassive,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        prefixIcon:
                            Icon(Icons.location_on, color: QPColors.brandFair),
                        filled: true,
                        fillColor: QPColors.whiteMassive,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Enter your location',
                        hintStyle: QPTextStyle.subHeading4Regular.copyWith(
                          color: QPColors.blackFair,
                        ),
                        labelStyle: QPTextStyle.subHeading4Regular.copyWith(
                          color: QPColors.blackFair,
                        ),
                      ),
                    ),
                    SizedBox(height: 48),
                    Text(
                      'Selecting a location manually, disables your Auto-detect Location. You may enable it again in Settings.',
                      style: QPTextStyle.subHeading4SemiBold.copyWith(
                        color: QPColors.blackSoft,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
