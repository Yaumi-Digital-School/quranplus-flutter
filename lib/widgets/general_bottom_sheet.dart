import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class GeneralBottomSheet {
  Future showGeneralBottomSheet(
      BuildContext context, String label, Widget widgetChild) {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Container(
              height: 56,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16), bottom: Radius.zero),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 15,
                      offset: Offset(4, 12))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    height: 5,
                    width: 64,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: neutral400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: bodyRegular3.apply(color: neutral500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            widgetChild,
          ],
        );
      },
    );
  }

  Future showNoInternetBottomSheet(
      BuildContext context, Function() onRefreshClicked) {
    return showGeneralBottomSheet(
      context,
      '',
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'images/icon_no_wifi.png',
              width: 36,
            ),
            const SizedBox(height: 8),
            Text(
              'No Internet Connection',
              style: subHeadingSemiBold1,
            ),
            const SizedBox(height: 28),
            TextButton.icon(
              icon: Image.asset(
                'images/icon_refresh.png',
                width: 24,
              ),
              label: Text(
                'Refresh',
                style: captionSemiBold1.apply(color: primary500),
              ),
              onPressed: onRefreshClicked,
            ),
          ],
        ),
      ),
    );
  }
}
