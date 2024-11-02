import 'package:json_annotation/json_annotation.dart';

part 'city.g.dart';

@JsonSerializable()
class CityPosition {
  final double lat;
  final double lng;

  CityPosition({required this.lat, required this.lng});

  factory CityPosition.fromJson(Map<String, dynamic> json) =>
      _$CityPositionFromJson(json);
}

@JsonSerializable()
class CityResponse {
  final String id;
  final String title;
  final String label;
  final String? countryCode;
  final String? countryName;
  final String? county;
  final String city;
  final String? postalCode;
  final CityPosition? position;

  CityResponse({
    required this.id,
    required this.title,
    required this.label,
    required this.countryCode,
    required this.countryName,
    required this.county,
    required this.city,
    required this.postalCode,
    required this.position,
  });

  factory CityResponse.fromJson(Map<String, dynamic> json) =>
      _$CityResponseFromJson(json);
}
