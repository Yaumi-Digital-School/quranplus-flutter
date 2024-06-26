import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_view.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_group_summary.dart';
import 'package:qurantafsir_flutter/widgets/habit_group_overview.dart';

class HabitGroupListView extends StatelessWidget {
  const HabitGroupListView({
    required this.listGroup,
    this.onEditedGroupName,
    Key? key,
  }) : super(key: key);

  final List<GetHabitGroupsItem> listGroup;
  final Future<void> Function()? onEditedGroupName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your habit group',
              style: QPTextStyle.getSubHeading2SemiBold(context),
            ),
            Text(
              '${listGroup.length} groups',
              style: QPTextStyle.getDescription2Regular(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: listGroup.length,
            itemBuilder: (BuildContext context, int index) {
              final GetHabitGroupsItem item = listGroup[index];
              final List<HabitGroupSummary> sevenDaysInformation =
                  item.completions
                      .map(
                        (element) =>
                            HabitGroupSummary.fromGetGroupListCompletionItem(
                          element,
                        ),
                      )
                      .toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: HabitGroupOverviewWidget(
                  startOfEnabledDate: item.joinDate,
                  totalMembers: item.currentMemberCount,
                  groupName: item.name,
                  sevenDaysInformation: sevenDaysInformation,
                  onTapGroupDetailCTA: () async {
                    final res = await Navigator.pushNamed(
                      context,
                      RoutePaths.routeHabitGroupDetail,
                      arguments: HabitGroupDetailViewParam(
                        id: item.id,
                      ),
                    );

                    if (res is bool && res && onEditedGroupName != null) {
                      await onEditedGroupName!();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
