import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkHelper {
  static const String uriPrefix = 'https://quranplus.page.link';
  static const String packageName = 'com.yaumi.qurantafsir.id';
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  DynamicLinkParameters _buildParameters(Uri link) {
    return DynamicLinkParameters(
      uriPrefix: uriPrefix,
      link: link,
      androidParameters: const AndroidParameters(
        packageName: packageName,
        minimumVersion: 25,
      ),
      iosParameters: const IOSParameters(
        bundleId: packageName,
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
