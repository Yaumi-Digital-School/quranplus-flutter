import 'package:json_annotation/json_annotation.dart';

part 'force_login_param.g.dart';

@JsonSerializable()
class ForceLoginParam {
  ForceLoginParam({
    this.nextPath,
    this.arguments,
  });

  final String? nextPath;
  final Map<String, dynamic>? arguments;

  factory ForceLoginParam.fromJson(Map<String, dynamic> json) =>
      _$ForceLoginParamFromJson(json);

  Map<String, dynamic> toJson() => _$ForceLoginParamToJson(this);
}
