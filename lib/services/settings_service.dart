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

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_preset.dart';
import '../themes/app_themes.dart';

class SettingsService {
  // API服务类型
  static const String _plantIdentificationApiTypeKey = 'plant_identification_api_type';

  // iNaturalist 设置
  static const String _inaturalistApiUrlKey = 'inaturalist_api_url';
  static const String _inaturalistTokenKey = 'inaturalist_token';

  // LLM API 设置
  static const String _llmApiUrlKey = 'llm_api_url';
  static const String _llmApiKeyKey = 'llm_api_key';
  static const String _llmModelKey = 'llm_model';

  // VLM API 设置
  static const String _vlmApiUrlKey = 'vlm_api_url';
  static const String _vlmApiKeyKey = 'vlm_api_key';
  static const String _vlmModelKey = 'vlm_model';

  // Plant.id API 设置
  static const String _plantIdApiKeyKey = 'plant_id_api_key';

  // Weather API 设置
  static const String _weatherApiKeyKey = 'weather_api_key';
  static const String _weatherApiUrlKey = 'weather_api_url';

  // 主题设置
  static const String _themeTypeKey = 'theme_type';

  // API预设
  static const String _apiPresetsKey = 'api_presets';
  static const String _activeApiPresetIdKey = 'active_api_preset_id';

  Future<List<ApiPreset>> getApiPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_apiPresetsKey);

    if (jsonString == null) {
      final defaultPreset = _createPresetFromLegacy(prefs);
      await prefs.setString(
        _apiPresetsKey,
        jsonEncode([defaultPreset.toJson()]),
      );
      await prefs.setString(_activeApiPresetIdKey, defaultPreset.id);
      await _writeLegacyValues(prefs, defaultPreset);
      return [defaultPreset];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      final presets = decoded
          .map((item) => ApiPreset.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      if (presets.isEmpty) {
        final fallbackPreset = _createPresetFromLegacy(prefs);
        await setApiPresets([fallbackPreset]);
        await setActiveApiPresetId(fallbackPreset.id);
        return [fallbackPreset];
      }

      return presets;
    } catch (_) {
      final fallbackPreset = _createPresetFromLegacy(prefs);
      await prefs.setString(
        _apiPresetsKey,
        jsonEncode([fallbackPreset.toJson()]),
      );
      await prefs.setString(_activeApiPresetIdKey, fallbackPreset.id);
      await _writeLegacyValues(prefs, fallbackPreset);
      return [fallbackPreset];
    }
  }

  Future<void> setApiPresets(List<ApiPreset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(presets.map((preset) => preset.toJson()).toList());
    await prefs.setString(_apiPresetsKey, encoded);

    if (presets.isEmpty) {
      await prefs.remove(_activeApiPresetIdKey);
      return;
    }

    final String? storedActiveId = await getActiveApiPresetId();
    final ApiPreset activePreset = _resolveActivePreset(presets, storedActiveId);

    if (storedActiveId == null || storedActiveId != activePreset.id) {
      await prefs.setString(_activeApiPresetIdKey, activePreset.id);
    }

    await _writeLegacyValues(prefs, activePreset);
  }

  Future<String?> getActiveApiPresetId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeApiPresetIdKey);
  }

  Future<void> setActiveApiPresetId(String? presetId) async {
    final prefs = await SharedPreferences.getInstance();

    if (presetId == null || presetId.isEmpty) {
      await prefs.remove(_activeApiPresetIdKey);
    } else {
      await prefs.setString(_activeApiPresetIdKey, presetId);
    }

    final presets = await getApiPresets();
    if (presets.isEmpty) {
      return;
    }

    final ApiPreset activePreset = _resolveActivePreset(presets, presetId);
    await prefs.setString(_activeApiPresetIdKey, activePreset.id);
    await _writeLegacyValues(prefs, activePreset);
  }

  Future<ApiPreset?> getActiveApiPreset() async {
    final presets = await getApiPresets();
    if (presets.isEmpty) {
      return null;
    }

    final String? activeId = await getActiveApiPresetId();
    return _resolveActivePreset(presets, activeId);
  }

  // 植物识别API类型 (inaturalist, plantid, vlm)
  Future<String> getPlantIdentificationApiType() async {
    final preset = await getActiveApiPreset();
    return preset?.plantApiType ?? 'inaturalist';
  }

  Future<void> setPlantIdentificationApiType(String type) async {
    await _updateActivePreset((preset) => preset.copyWith(plantApiType: type));
  }

  // iNaturalist 设置
  Future<String> getINaturalistApiUrl() async {
    final preset = await getActiveApiPreset();
    return preset?.inaturalistApiUrl ?? 'https://api.inaturalist.org';
  }

  Future<void> setINaturalistApiUrl(String url) async {
    await _updateActivePreset((preset) => preset.copyWith(inaturalistApiUrl: url));
  }

  Future<String> getINaturalistToken() async {
    final preset = await getActiveApiPreset();
    return preset?.inaturalistToken ?? '';
  }

  Future<void> setINaturalistToken(String token) async {
    await _updateActivePreset((preset) => preset.copyWith(inaturalistToken: token));
  }

  // LLM API 设置
  Future<String> getLLMApiUrl() async {
    final preset = await getActiveApiPreset();
    return preset?.llmApiUrl ?? 'https://api.openai.com';
  }

  Future<void> setLLMApiUrl(String url) async {
    await _updateActivePreset((preset) => preset.copyWith(llmApiUrl: url));
  }

  Future<String> getLLMApiKey() async {
    final preset = await getActiveApiPreset();
    return preset?.llmApiKey ?? '';
  }

  Future<void> setLLMApiKey(String apiKey) async {
    await _updateActivePreset((preset) => preset.copyWith(llmApiKey: apiKey));
  }

  Future<String> getLLMModel() async {
    final preset = await getActiveApiPreset();
    return preset?.llmModel ?? 'gpt-4';
  }

  Future<void> setLLMModel(String model) async {
    await _updateActivePreset((preset) => preset.copyWith(llmModel: model));
  }

  // VLM API 设置
  Future<String> getVLMApiUrl() async {
    final preset = await getActiveApiPreset();
    return preset?.vlmApiUrl ?? 'https://api.openai.com';
  }

  Future<void> setVLMApiUrl(String url) async {
    await _updateActivePreset((preset) => preset.copyWith(vlmApiUrl: url));
  }

  Future<String> getVLMApiKey() async {
    final preset = await getActiveApiPreset();
    return preset?.vlmApiKey ?? '';
  }

  Future<void> setVLMApiKey(String apiKey) async {
    await _updateActivePreset((preset) => preset.copyWith(vlmApiKey: apiKey));
  }

  Future<String> getVLMModel() async {
    final preset = await getActiveApiPreset();
    return preset?.vlmModel ?? 'gpt-4-vision-preview';
  }

  Future<void> setVLMModel(String model) async {
    await _updateActivePreset((preset) => preset.copyWith(vlmModel: model));
  }

  // Plant.id API 设置
  Future<String> getPlantIdApiKey() async {
    final preset = await getActiveApiPreset();
    return preset?.plantIdApiKey ?? '';
  }

  Future<void> setPlantIdApiKey(String apiKey) async {
    await _updateActivePreset((preset) => preset.copyWith(plantIdApiKey: apiKey));
  }

  // Weather API 设置
  Future<String> getWeatherApiKey() async {
    final preset = await getActiveApiPreset();
    return preset?.weatherApiKey ?? '';
  }

  Future<void> setWeatherApiKey(String apiKey) async {
    await _updateActivePreset((preset) => preset.copyWith(weatherApiKey: apiKey));
  }

  Future<String> getWeatherApiUrl() async {
    final preset = await getActiveApiPreset();
    return preset?.weatherApiUrl ?? 'https://api.weatherapi.com/v1';
  }

  Future<void> setWeatherApiUrl(String url) async {
    await _updateActivePreset((preset) => preset.copyWith(weatherApiUrl: url));
  }

  // 主题相关方法
  Future<AppThemeType> getThemeType() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeTypeKey) ?? 'dynamic';
    return themeString == 'dynamic' ? AppThemeType.dynamic : AppThemeType.minimal;
  }

  Future<void> setThemeType(AppThemeType themeType) async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = themeType == AppThemeType.dynamic ? 'dynamic' : 'minimal';
    await prefs.setString(_themeTypeKey, themeString);
  }

  // 验证设置完整性
  Future<bool> areSettingsComplete() async {
    final preset = await getActiveApiPreset();
    if (preset == null) return false;
    if (preset.weatherApiKey.isEmpty) return false;

    switch (preset.plantApiType) {
      case 'inaturalist':
        return preset.inaturalistToken.isNotEmpty;
      case 'plantid':
        return preset.plantIdApiKey.isNotEmpty;
      case 'vlm':
        return preset.vlmApiKey.isNotEmpty && preset.llmApiKey.isNotEmpty;
      default:
        return false;
    }
  }

  ApiPreset _createPresetFromLegacy(SharedPreferences prefs) {
    return ApiPreset(
      id: 'preset_default',
      name: '默认预设',
      plantApiType: prefs.getString(_plantIdentificationApiTypeKey) ?? 'inaturalist',
      inaturalistApiUrl: prefs.getString(_inaturalistApiUrlKey) ?? 'https://api.inaturalist.org',
      inaturalistToken: prefs.getString(_inaturalistTokenKey) ?? '',
      plantIdApiKey: prefs.getString(_plantIdApiKeyKey) ?? '',
      llmApiUrl: prefs.getString(_llmApiUrlKey) ?? 'https://api.openai.com',
      llmApiKey: prefs.getString(_llmApiKeyKey) ?? '',
      llmModel: prefs.getString(_llmModelKey) ?? 'gpt-4',
      vlmApiUrl: prefs.getString(_vlmApiUrlKey) ?? 'https://api.openai.com',
      vlmApiKey: prefs.getString(_vlmApiKeyKey) ?? '',
      vlmModel: prefs.getString(_vlmModelKey) ?? 'gpt-4-vision-preview',
      weatherApiUrl: prefs.getString(_weatherApiUrlKey) ?? 'https://api.weatherapi.com/v1',
      weatherApiKey: prefs.getString(_weatherApiKeyKey) ?? '',
    );
  }

  ApiPreset _resolveActivePreset(List<ApiPreset> presets, String? activeId) {
    if (presets.isEmpty) {
      return ApiPreset.empty(id: 'preset_default', name: '默认预设');
    }

    if (activeId != null && activeId.isNotEmpty) {
      for (final preset in presets) {
        if (preset.id == activeId) {
          return preset;
        }
      }
    }

    return presets.first;
  }

  Future<void> _writeLegacyValues(SharedPreferences prefs, ApiPreset preset) async {
    await prefs.setString(_plantIdentificationApiTypeKey, preset.plantApiType);
    await prefs.setString(_inaturalistApiUrlKey, preset.inaturalistApiUrl);
    await prefs.setString(_inaturalistTokenKey, preset.inaturalistToken);
    await prefs.setString(_plantIdApiKeyKey, preset.plantIdApiKey);
    await prefs.setString(_llmApiUrlKey, preset.llmApiUrl);
    await prefs.setString(_llmApiKeyKey, preset.llmApiKey);
    await prefs.setString(_llmModelKey, preset.llmModel);
    await prefs.setString(_vlmApiUrlKey, preset.vlmApiUrl);
    await prefs.setString(_vlmApiKeyKey, preset.vlmApiKey);
    await prefs.setString(_vlmModelKey, preset.vlmModel);
    await prefs.setString(_weatherApiUrlKey, preset.weatherApiUrl);
    await prefs.setString(_weatherApiKeyKey, preset.weatherApiKey);
  }

  Future<void> _updateActivePreset(ApiPreset Function(ApiPreset) transform) async {
    List<ApiPreset> presets = await getApiPresets();

    if (presets.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final defaultPreset = _createPresetFromLegacy(prefs);
      presets = [defaultPreset];
      await prefs.setString(
        _apiPresetsKey,
        jsonEncode([defaultPreset.toJson()]),
      );
      await prefs.setString(_activeApiPresetIdKey, defaultPreset.id);
      await _writeLegacyValues(prefs, defaultPreset);
    }

    final String? activeId = await getActiveApiPresetId();
    final ApiPreset current = _resolveActivePreset(presets, activeId);
    final ApiPreset updated = transform(current);
    final List<ApiPreset> updatedPresets = presets
        .map((preset) => preset.id == updated.id ? updated : preset)
        .toList();

    await setApiPresets(updatedPresets);
    await setActiveApiPresetId(updated.id);
  }
}
