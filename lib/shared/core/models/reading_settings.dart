import 'package:json_annotation/json_annotation.dart';

part 'reading_settings.g.dart';

@JsonSerializable()
class ReadingSettings {
  ReadingSettings({
    this.isWithTafsirs = true,
    this.isWithLatins = true,
    this.isWithTranslations = true,
  });

  bool isWithTafsirs;
  bool isWithLatins;
  bool isWithTranslations;

  factory ReadingSettings.fromJson(Map<String, dynamic> json) =>
      _$ReadingSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingSettingsToJson(this);

  ReadingSettings copyWith({
    bool? isWithTafsirs,
    bool? isWithLatins,
    bool? isWithTranslations,
  }) {
    return ReadingSettings(
      isWithTafsirs: isWithTafsirs ?? this.isWithTafsirs,
      isWithLatins: isWithLatins ?? this.isWithLatins,
      isWithTranslations: isWithTranslations ?? this.isWithTranslations,
    );
  }
}
