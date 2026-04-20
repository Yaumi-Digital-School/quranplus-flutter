class DynamicLinkHelper {
  static const String uriPrefix = 'https://quranplus.page.link';

  Future<Uri> createDynamicLinkInvite({required int id}) async {
    return Uri.parse('$uriPrefix/RtQw?id=$id');
  }
}
