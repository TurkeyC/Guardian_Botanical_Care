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

class ApiPreset {
  final String id;
  final String name;
  final String plantApiType;
  final String inaturalistApiUrl;
  final String inaturalistToken;
  final String plantIdApiKey;
  final String llmApiUrl;
  final String llmApiKey;
  final String llmModel;
  final String vlmApiUrl;
  final String vlmApiKey;
  final String vlmModel;
  final String weatherApiUrl;
  final String weatherApiKey;

  const ApiPreset({
    required this.id,
    required this.name,
    required this.plantApiType,
    required this.inaturalistApiUrl,
    required this.inaturalistToken,
    required this.plantIdApiKey,
    required this.llmApiUrl,
    required this.llmApiKey,
    required this.llmModel,
    required this.vlmApiUrl,
    required this.vlmApiKey,
    required this.vlmModel,
    required this.weatherApiUrl,
    required this.weatherApiKey,
  });

  factory ApiPreset.fromJson(Map<String, dynamic> json) {
    return ApiPreset(
      id: json['id'] as String,
      name: json['name'] as String? ?? '未命名预设',
      plantApiType: json['plantApiType'] as String? ?? 'inaturalist',
      inaturalistApiUrl: json['inaturalistApiUrl'] as String? ?? 'https://api.inaturalist.org',
      inaturalistToken: json['inaturalistToken'] as String? ?? '',
      plantIdApiKey: json['plantIdApiKey'] as String? ?? '',
      llmApiUrl: json['llmApiUrl'] as String? ?? 'https://api.openai.com',
      llmApiKey: json['llmApiKey'] as String? ?? '',
      llmModel: json['llmModel'] as String? ?? 'gpt-4',
      vlmApiUrl: json['vlmApiUrl'] as String? ?? 'https://api.openai.com',
      vlmApiKey: json['vlmApiKey'] as String? ?? '',
      vlmModel: json['vlmModel'] as String? ?? 'gpt-4-vision-preview',
      weatherApiUrl: json['weatherApiUrl'] as String? ?? 'https://api.weatherapi.com/v1',
      weatherApiKey: json['weatherApiKey'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plantApiType': plantApiType,
      'inaturalistApiUrl': inaturalistApiUrl,
      'inaturalistToken': inaturalistToken,
      'plantIdApiKey': plantIdApiKey,
      'llmApiUrl': llmApiUrl,
      'llmApiKey': llmApiKey,
      'llmModel': llmModel,
      'vlmApiUrl': vlmApiUrl,
      'vlmApiKey': vlmApiKey,
      'vlmModel': vlmModel,
      'weatherApiUrl': weatherApiUrl,
      'weatherApiKey': weatherApiKey,
    };
  }

  ApiPreset copyWith({
    String? id,
    String? name,
    String? plantApiType,
    String? inaturalistApiUrl,
    String? inaturalistToken,
    String? plantIdApiKey,
    String? llmApiUrl,
    String? llmApiKey,
    String? llmModel,
    String? vlmApiUrl,
    String? vlmApiKey,
    String? vlmModel,
    String? weatherApiUrl,
    String? weatherApiKey,
  }) {
    return ApiPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      plantApiType: plantApiType ?? this.plantApiType,
      inaturalistApiUrl: inaturalistApiUrl ?? this.inaturalistApiUrl,
      inaturalistToken: inaturalistToken ?? this.inaturalistToken,
      plantIdApiKey: plantIdApiKey ?? this.plantIdApiKey,
      llmApiUrl: llmApiUrl ?? this.llmApiUrl,
      llmApiKey: llmApiKey ?? this.llmApiKey,
      llmModel: llmModel ?? this.llmModel,
      vlmApiUrl: vlmApiUrl ?? this.vlmApiUrl,
      vlmApiKey: vlmApiKey ?? this.vlmApiKey,
      vlmModel: vlmModel ?? this.vlmModel,
      weatherApiUrl: weatherApiUrl ?? this.weatherApiUrl,
      weatherApiKey: weatherApiKey ?? this.weatherApiKey,
    );
  }

  static ApiPreset empty({
    required String id,
    required String name,
  }) {
    return ApiPreset(
      id: id,
      name: name,
      plantApiType: 'inaturalist',
      inaturalistApiUrl: 'https://api.inaturalist.org',
      inaturalistToken: '',
      plantIdApiKey: '',
      llmApiUrl: 'https://api.openai.com',
      llmApiKey: '',
      llmModel: 'gpt-4',
      vlmApiUrl: 'https://api.openai.com',
      vlmApiKey: '',
      vlmModel: 'gpt-4-vision-preview',
      weatherApiUrl: 'https://api.weatherapi.com/v1',
      weatherApiKey: '',
    );
  }
}
