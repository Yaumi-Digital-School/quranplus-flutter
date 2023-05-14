import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/core/models/prayer.dart';

import '../../shared/constants/qp_colors.dart';
import '../../shared/constants/qp_text_style.dart';
import '../../shared/ui/state_notifier_connector.dart';
import 'notification_reminder_page_state_notifier.dart';

class NotificationReminderPage extends StatefulWidget {
  const NotificationReminderPage({
    Key? key,
  }) : super(key: key);

  @override
  State<NotificationReminderPage> createState() =>
      _NotificationReminderPageState();
}

class _NotificationReminderPageState extends State<NotificationReminderPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StateNotifierConnector<NotificationReminderStateNotifier,
        NotificationReminderPageState>(
      onStateNotifierReady: (
        NotificationReminderStateNotifier notifier,
        WidgetRef ref,
      ) async {
        await notifier.initStateNotifier();
      },
      stateNotifierProvider: StateNotifierProvider<
          NotificationReminderStateNotifier,
          NotificationReminderPageState>((ref) {
        return NotificationReminderStateNotifier();
      }),
      builder: (
        _,
        NotificationReminderPageState state,
        NotificationReminderStateNotifier notifier,
        WidgetRef ref,
      ) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: QPColors.background,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: QPColors.blackFair,
              ),
              onPressed: () {
                // Add your back button logic here
                SystemNavigator.pop();
              },
            ),
            centerTitle: true,
            title: Text(
              'Notification',
              style: QPTextStyle.subHeading1SemiBold.copyWith(
                color: QPColors.brandFair,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 160,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(ImagePath.notificationCardBg),
                            fit: BoxFit.fitWidth,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Center(
                              child: Text(
                                "Adzan Notification",
                                style: QPTextStyle.subHeading1SemiBold.copyWith(
                                  color: QPColors.blackFair,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: state.items?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              final item = state.items![index];

                              return ListTile(
                                leading: Container(
                                  width:
                                      24, // set the desired width of the image
                                  height:
                                      24, // set the desired height of the image
                                  child: Image.asset(
                                    item.image,
                                  ),
                                ),
                                title: Text(
                                  item.prayerNames,
                                  style:
                                      QPTextStyle.subHeading3SemiBold.copyWith(
                                    color: QPColors.blackFair,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      notifier.formatDateTime(item.prayerTime),
                                      style: QPTextStyle.subHeading3SemiBold
                                          .copyWith(
                                        color: QPColors.blackFair,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Switch(
                                      value: item.alarm,
                                      activeColor: QPColors.brandHeavy,
                                      onChanged: (bool newValue) {
                                        notifier.onAlarmPressed(
                                          newValue,
                                          item.index,
                                          item.prayerTime,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
