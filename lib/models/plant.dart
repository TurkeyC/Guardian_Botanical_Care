// Guardian Botanical Care (gbc_flutter)
// Copyright (C) 2025 <Cao Turkey>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:json_annotation/json_annotation.dart';

part 'plant.g.dart';

@JsonSerializable()
class Plant {
  final String id;
  final String name;
  final String scientificName;
  final String imagePath;
  final DateTime identificationDate;
  final String healthStatus;
  final double confidence;
  final String careInstructions;
  final String wateringFrequency;
  final String lightRequirement;
  final String fertilizingSchedule;

  const Plant({
    required this.id,
    required this.name,
    this.scientificName = '',
    required this.imagePath,
    required this.identificationDate,
    required this.healthStatus,
    this.confidence = 0.0,
    this.careInstructions = '',
    this.wateringFrequency = '',
    this.lightRequirement = '',
    this.fertilizingSchedule = '',
  });

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
  Map<String, dynamic> toJson() => _$PlantToJson(this);
}

@JsonSerializable()
class PlantIdentificationResult {
  final String species;
  final String scientificName;
  final double confidence;
  final String healthAnalysis;
  final String careRecommendations;
  final String imagePath;

  const PlantIdentificationResult({
    required this.species,
    required this.scientificName,
    required this.confidence,
    required this.healthAnalysis,
    required this.careRecommendations,
    required this.imagePath,
  });

  factory PlantIdentificationResult.fromJson(Map<String, dynamic> json) =>
      _$PlantIdentificationResultFromJson(json);
  Map<String, dynamic> toJson() => _$PlantIdentificationResultToJson(this);
}

@JsonSerializable()
class INaturalistResponse {
  final List<INaturalistResult> results;

  const INaturalistResponse({required this.results});

  factory INaturalistResponse.fromJson(Map<String, dynamic> json) =>
      _$INaturalistResponseFromJson(json);
  Map<String, dynamic> toJson() => _$INaturalistResponseToJson(this);
}

@JsonSerializable()
class INaturalistResult {
  final Taxon taxon;
  final double score;

  const INaturalistResult({required this.taxon, required this.score});

  factory INaturalistResult.fromJson(Map<String, dynamic> json) =>
      _$INaturalistResultFromJson(json);
  Map<String, dynamic> toJson() => _$INaturalistResultToJson(this);
}

@JsonSerializable()
class Taxon {
  final String name;
  @JsonKey(name: 'preferred_common_name')
  final String? preferredCommonName;

  const Taxon({required this.name, this.preferredCommonName});

  factory Taxon.fromJson(Map<String, dynamic> json) => _$TaxonFromJson(json);
  Map<String, dynamic> toJson() => _$TaxonToJson(this);
}

@JsonSerializable()
class OpenAIRequest {
  final String model;
  final List<Message> messages;
  @JsonKey(name: 'max_tokens')
  final int maxTokens;

  const OpenAIRequest({
    required this.model,
    required this.messages,
    this.maxTokens = 1000,
  });

  factory OpenAIRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAIRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OpenAIRequestToJson(this);
}

@JsonSerializable()
class Message {
  final String role;
  final dynamic content; // 可以是String或List<Content>

  const Message({required this.role, required this.content});

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Content {
  final String type;
  final String? text;
  @JsonKey(name: 'image_url')
  final ImageUrl? imageUrl;

  const Content({required this.type, this.text, this.imageUrl});

  factory Content.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);
  Map<String, dynamic> toJson() => _$ContentToJson(this);
}

@JsonSerializable()
class ImageUrl {
  final String url;

  const ImageUrl({required this.url});

  factory ImageUrl.fromJson(Map<String, dynamic> json) =>
      _$ImageUrlFromJson(json);
  Map<String, dynamic> toJson() => _$ImageUrlToJson(this);
}

@JsonSerializable()
class OpenAIResponse {
  final List<Choice> choices;

  const OpenAIResponse({required this.choices});

  factory OpenAIResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenAIResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OpenAIResponseToJson(this);
}

@JsonSerializable()
class Choice {
  final Message message;

  const Choice({required this.message});

  factory Choice.fromJson(Map<String, dynamic> json) =>
      _$ChoiceFromJson(json);
  Map<String, dynamic> toJson() => _$ChoiceToJson(this);
}

@JsonSerializable()
class WeatherInfo {
  final Location location;
  final Current current;

  const WeatherInfo({
    required this.location,
    required this.current,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherInfoToJson(this);
}

@JsonSerializable()
class Location {
  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;

  const Location({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class Current {
  @JsonKey(name: 'temp_c')
  final double tempC;
  @JsonKey(name: 'temp_f')
  final double tempF;
  final Condition condition;
  @JsonKey(name: 'wind_kph')
  final double windKph;
  final int humidity;
  @JsonKey(name: 'feelslike_c')
  final double feelslikeC;
  final double uv;

  const Current({
    required this.tempC,
    required this.tempF,
    required this.condition,
    required this.windKph,
    required this.humidity,
    required this.feelslikeC,
    required this.uv,
  });

  factory Current.fromJson(Map<String, dynamic> json) =>
      _$CurrentFromJson(json);
  Map<String, dynamic> toJson() => _$CurrentToJson(this);
}

@JsonSerializable()
class Condition {
  final String text;
  final String icon;

  const Condition({
    required this.text,
    required this.icon,
  });

  factory Condition.fromJson(Map<String, dynamic> json) =>
      _$ConditionFromJson(json);
  Map<String, dynamic> toJson() => _$ConditionToJson(this);
}
