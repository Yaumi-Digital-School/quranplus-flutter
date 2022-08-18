import 'package:json_annotation/json_annotation.dart';

part 'full_page_separator.g.dart';

@JsonSerializable()
class FullPageSeparatorList {
  FullPageSeparatorList({
    required this.separators,
  });

  final List<FullPageSeparator> separators;

  factory FullPageSeparatorList.fromJson(Map<String, dynamic> json) =>
      _$FullPageSeparatorListFromJson(json);

  factory FullPageSeparatorList.fromArray(List<dynamic> arr) {
    List<FullPageSeparator> separators = <FullPageSeparator>[];
    arr.forEach((dynamic element) {
      Map<String, dynamic> v = element as Map<String, dynamic>;
      FullPageSeparator separator = FullPageSeparator.fromJson(v);

      separators.add(separator);
    });

    return FullPageSeparatorList(separators: separators);
  }
}

@JsonSerializable()
class FullPageSeparator {
  FullPageSeparator({
    required this.page,
    required this.line,
    this.unicode,
    this.bismillah = false,
  });

  final int page;
  final int line;
  final String? unicode;
  final bool bismillah;

  factory FullPageSeparator.fromJson(Map<String, dynamic> json) =>
      _$FullPageSeparatorFromJson(json);
}
