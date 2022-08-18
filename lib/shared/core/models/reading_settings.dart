import 'package:json_annotation/json_annotation.dart';

part 'reading_settings.g.dart';

@JsonSerializable()
class ReadingSettings {
  ReadingSettings({
    this.isWithTafsirs = true,
    this.isWithLatins = true,
    this.isWithTranslations = true,
    this.fontSize = 1,
    this.valueFontSize = 12,
    this.valueFontSizeArabic = 24,
    this.isInFullPage = false,
  });

  bool isWithTafsirs;
  bool isWithLatins;
  bool isWithTranslations;
  int fontSize;
  double valueFontSize;
  double valueFontSizeArabic;
  bool isInFullPage;

  factory ReadingSettings.fromJson(Map<String, dynamic> json) =>
      _$ReadingSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingSettingsToJson(this);

  ReadingSettings copyWith({
    bool? isWithTafsirs,
    bool? isWithLatins,
    bool? isWithTranslations,
    double? valueFontSize,
    double? valueFontSizeArabic,
    int? fontSize,
    bool? isInFullPage,
  }) {
    return ReadingSettings(
      isWithTafsirs: isWithTafsirs ?? this.isWithTafsirs,
      isWithLatins: isWithLatins ?? this.isWithLatins,
      isWithTranslations: isWithTranslations ?? this.isWithTranslations,
      valueFontSize: valueFontSize ?? this.valueFontSize,
      valueFontSizeArabic: valueFontSizeArabic ?? this.valueFontSizeArabic,
      fontSize: fontSize ?? this.fontSize,
      isInFullPage: isInFullPage ?? this.isInFullPage,
    );
  }
}
