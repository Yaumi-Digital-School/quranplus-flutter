import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkHelper {
  static const uriPrefix = 'https://quranplus.page.link';
  static const androidPackageName = 'com.yaumi.qurantafsir.id';
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  DynamicLinkParameters _buildParameters(Uri link) {
    return DynamicLinkParameters(
      uriPrefix: uriPrefix,
      link: link,
      androidParameters: const AndroidParameters(
        packageName: androidPackageName,
        minimumVersion: 25,
      ),
    );
  }

  Future<Uri> createDynamicLinkInvite({required int id}) async {
    final dynamicLink = 'https://quranplus.page.link/RtQw?id=$id';
    final link = Uri.parse(dynamicLink);
    final parameters = _buildParameters(link);

    final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(
      parameters,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );

    return shortLink.shortUrl;
  }
}
