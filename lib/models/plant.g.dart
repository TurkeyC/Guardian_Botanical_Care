// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plant _$PlantFromJson(Map<String, dynamic> json) => Plant(
  id: json['id'] as String,
  name: json['name'] as String,
  scientificName: json['scientificName'] as String? ?? '',
  imagePath: json['imagePath'] as String,
  identificationDate: DateTime.parse(json['identificationDate'] as String),
  healthStatus: json['healthStatus'] as String,
  confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
  careInstructions: json['careInstructions'] as String? ?? '',
  wateringFrequency: json['wateringFrequency'] as String? ?? '',
  lightRequirement: json['lightRequirement'] as String? ?? '',
  fertilizingSchedule: json['fertilizingSchedule'] as String? ?? '',
);

Map<String, dynamic> _$PlantToJson(Plant instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'scientificName': instance.scientificName,
  'imagePath': instance.imagePath,
  'identificationDate': instance.identificationDate.toIso8601String(),
  'healthStatus': instance.healthStatus,
  'confidence': instance.confidence,
  'careInstructions': instance.careInstructions,
  'wateringFrequency': instance.wateringFrequency,
  'lightRequirement': instance.lightRequirement,
  'fertilizingSchedule': instance.fertilizingSchedule,
};

PlantIdentificationResult _$PlantIdentificationResultFromJson(
  Map<String, dynamic> json,
) => PlantIdentificationResult(
  species: json['species'] as String,
  scientificName: json['scientificName'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  healthAnalysis: json['healthAnalysis'] as String,
  careRecommendations: json['careRecommendations'] as String,
  imagePath: json['imagePath'] as String,
);

Map<String, dynamic> _$PlantIdentificationResultToJson(
  PlantIdentificationResult instance,
) => <String, dynamic>{
  'species': instance.species,
  'scientificName': instance.scientificName,
  'confidence': instance.confidence,
  'healthAnalysis': instance.healthAnalysis,
  'careRecommendations': instance.careRecommendations,
  'imagePath': instance.imagePath,
};

INaturalistResponse _$INaturalistResponseFromJson(Map<String, dynamic> json) =>
    INaturalistResponse(
      results:
          (json['results'] as List<dynamic>)
              .map((e) => INaturalistResult.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$INaturalistResponseToJson(
  INaturalistResponse instance,
) => <String, dynamic>{'results': instance.results};

INaturalistResult _$INaturalistResultFromJson(Map<String, dynamic> json) =>
    INaturalistResult(
      taxon: Taxon.fromJson(json['taxon'] as Map<String, dynamic>),
      score: (json['score'] as num).toDouble(),
    );

Map<String, dynamic> _$INaturalistResultToJson(INaturalistResult instance) =>
    <String, dynamic>{'taxon': instance.taxon, 'score': instance.score};

Taxon _$TaxonFromJson(Map<String, dynamic> json) => Taxon(
  name: json['name'] as String,
  preferredCommonName: json['preferred_common_name'] as String?,
);

Map<String, dynamic> _$TaxonToJson(Taxon instance) => <String, dynamic>{
  'name': instance.name,
  'preferred_common_name': instance.preferredCommonName,
};

OpenAIRequest _$OpenAIRequestFromJson(Map<String, dynamic> json) =>
    OpenAIRequest(
      model: json['model'] as String,
      messages:
          (json['messages'] as List<dynamic>)
              .map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList(),
      maxTokens: (json['max_tokens'] as num?)?.toInt() ?? 1000,
    );

Map<String, dynamic> _$OpenAIRequestToJson(OpenAIRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'messages': instance.messages,
      'max_tokens': instance.maxTokens,
    };

Message _$MessageFromJson(Map<String, dynamic> json) =>
    Message(role: json['role'] as String, content: json['content']);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'role': instance.role,
  'content': instance.content,
};

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
  type: json['type'] as String,
  text: json['text'] as String?,
  imageUrl:
      json['image_url'] == null
          ? null
          : ImageUrl.fromJson(json['image_url'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
  'type': instance.type,
  'text': instance.text,
  'image_url': instance.imageUrl,
};

ImageUrl _$ImageUrlFromJson(Map<String, dynamic> json) =>
    ImageUrl(url: json['url'] as String);

Map<String, dynamic> _$ImageUrlToJson(ImageUrl instance) => <String, dynamic>{
  'url': instance.url,
};

OpenAIResponse _$OpenAIResponseFromJson(Map<String, dynamic> json) =>
    OpenAIResponse(
      choices:
          (json['choices'] as List<dynamic>)
              .map((e) => Choice.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$OpenAIResponseToJson(OpenAIResponse instance) =>
    <String, dynamic>{'choices': instance.choices};

Choice _$ChoiceFromJson(Map<String, dynamic> json) =>
    Choice(message: Message.fromJson(json['message'] as Map<String, dynamic>));

Map<String, dynamic> _$ChoiceToJson(Choice instance) => <String, dynamic>{
  'message': instance.message,
};
