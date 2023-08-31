import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/user_summary.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart'
    as date_util_custom;

class UserSummaryBottomSheet {
  static void showBottomSheet({
    required BuildContext context,
    required UserSummaryResponse data,
    required bool isCurrentUser,
  }) {
    final name = isCurrentUser ? "Your Today's" : data.user.name;
    final title = "$name Progress";
    final date = date_util_custom.DateCustomUtils.stringToDate(
      data.date,
      DateFormatType.yyyyMMdd,
    );
    final dateInformation = DateFormat('EEEE, d MMMM yyyy').format(date);
    final pageWord = data.target > 1 ? "Pages" : "Page";
    final progressInformation = "${data.totalPages}/${data.target} $pageWord";
    double progress = data.totalPages / data.target;
    if (progress > 1) {
      progress = 1;
    }

    final emptyState = Column(
      children: [
        const Icon(
          Icons.history,
          size: 40,
          color: QPColors.whiteRoot,
        ),
        const SizedBox(height: 20),
        Text(
          "Progress history is here",
          style: QPTextStyle.getSubHeading3SemiBold(context)
              // Todo: check color based on theme
              .copyWith(color: QPColors.blackFair),
        ),
        const SizedBox(height: 12),
        Text(
          "It seems that ${isCurrentUser ? "you have" : "${data.user.name} has"} not made any progress",
          style: QPTextStyle.getSubHeading4Regular(context)
              // Todo: check color based on theme
              .copyWith(color: QPColors.blackFair),
        ),
      ],
    );

    final listProgressWidget = Scrollbar(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: data.habitProgresses.length,
        itemBuilder: ((context, index) {
          final item = data.habitProgresses[index];
          final notes = item.type == "RECORD"
              ? "Updated by Reading ${item.pages} page completed"
              : "Updated Manually";

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.history,
                  size: 12,
                  color: QPColors.brandFair,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description,
                        style: QPTextStyle.getSubHeading4Medium(context),
                      ),
                      Text(
                        notes,
                        style: QPTextStyle.getSubHeading4Regular(context)
                            // Todo: check color based on theme
                            .copyWith(color: QPColors.blackFair),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Text(
                  item.inputTime.substring(0, item.inputTime.length - 3),
                  style: QPTextStyle.getSubHeading4Regular(
                    context,
                  ) // Todo: check color based on theme
                      .copyWith(color: QPColors.blackFair),
                ),
              ],
            ),
          );
        }),
      ),
    );

    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: QPTextStyle.getSubHeading3SemiBold(context),
          ),
          Text(
            dateInformation,
            style: QPTextStyle.getButton2Medium(context).copyWith(
              // Todo: check color based on theme
              color: QPColors.blackSoft,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: LinearPercentIndicator(
                  animation: true,
                  lineHeight: 16.0,
                  animationDuration: 1000,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  percent: progress,
                  barRadius: const Radius.circular(8),
                  progressColor: QPColors.brandFair,
                  backgroundColor: QPColors.brandRoot,
                ),
              ),
              const SizedBox(width: 8),
              Text("${(progress * 100).floor()}%"),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            progressInformation,
            style: QPTextStyle.getBody3Regular(context).copyWith(
              // Todo: check color based on theme
              color: QPColors.blackFair,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Progress History",
            style: QPTextStyle.getSubHeading3SemiBold(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            width: double.infinity,
            child:
                data.habitProgresses.isEmpty ? emptyState : listProgressWidget,
          ),
        ],
      ),
    );
  }
}
