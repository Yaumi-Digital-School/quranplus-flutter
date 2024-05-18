import 'package:json_annotation/json_annotation.dart';

part 'city.g.dart';

@JsonSerializable()
class CityResponse {
  final String city;
  final String country;
  final String longitude;
  final String latitude;

  CityResponse({
    required this.city,
    required this.country,
    required this.longitude,
    required this.latitude,
  });

  factory CityResponse.fromJson(Map<String, dynamic> json) =>
      _$CityResponseFromJson(json);
}
