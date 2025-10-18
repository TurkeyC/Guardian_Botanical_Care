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

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_preset.dart';
import '../models/plant.dart'; // 添加Plant模型导入
import '../services/settings_service.dart';
import '../themes/app_themes.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  final Dio _dio = Dio();
  final Random _random = Random();

  List<ApiPreset> _apiPresets = [];
  String? _activeApiPresetId;

  // 植物识别API类型
  String _plantIdentificationApiType = 'inaturalist';

  // iNaturalist 设置
  String _inaturalistApiUrl = 'https://api.inaturalist.org';
  String _inaturalistToken = '';

  // LLM API 设置
  String _llmApiUrl = 'https://api.openai.com';
  String _llmApiKey = '';
  String _llmModel = 'gpt-4';

  // VLM API 设置
  String _vlmApiUrl = 'https://api.openai.com';
  String _vlmApiKey = '';
  String _vlmModel = 'gpt-4-vision-preview';

  // Plant.id API 设置
  String _plantIdApiKey = '';

  // Weather API 设置
  String _weatherApiKey = '';
  String _weatherApiUrl = 'https://api.weatherapi.com/v1';

  // 主题设置
  AppThemeType _currentTheme = AppThemeType.dynamic;

  // Demo模式设置
  bool _isDemoMode = false;

  bool _isLoading = false;
  String? _error;

  // Getters
  String get plantIdentificationApiType => _plantIdentificationApiType;
  String get inaturalistApiUrl => _inaturalistApiUrl;
  String get inaturalistToken => _inaturalistToken;
  String get llmApiUrl => _llmApiUrl;
  String get llmApiKey => _llmApiKey;
  String get llmModel => _llmModel;
  String get vlmApiUrl => _vlmApiUrl;
  String get vlmApiKey => _vlmApiKey;
  String get vlmModel => _vlmModel;
  String get plantIdApiKey => _plantIdApiKey;
  String get weatherApiKey => _weatherApiKey;
  String get weatherApiUrl => _weatherApiUrl;
  AppThemeType get currentTheme => _currentTheme;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDemoMode => _isDemoMode; // 添加Demo模式的getter
  List<ApiPreset> get apiPresets => List.unmodifiable(_apiPresets);
  String? get activeApiPresetId => _activeApiPresetId;
  ApiPreset? get activeApiPreset => _getActivePreset();

  /// 初始化设置
  Future<void> loadSettings() async {
    _setLoading(true);
    try {
      _currentTheme = await _settingsService.getThemeType();
      _apiPresets = await _settingsService.getApiPresets();
      _activeApiPresetId = await _settingsService.getActiveApiPresetId();
      if (_apiPresets.isNotEmpty &&
          (_activeApiPresetId == null ||
           !_apiPresets.any((preset) => preset.id == _activeApiPresetId))) {
        _activeApiPresetId = _apiPresets.first.id;
        await _settingsService.setActiveApiPresetId(_activeApiPresetId);
      }
      _plantIdentificationApiType = await _settingsService.getPlantIdentificationApiType();
      _inaturalistApiUrl = await _settingsService.getINaturalistApiUrl();
      _inaturalistToken = await _settingsService.getINaturalistToken();
      _llmApiUrl = await _settingsService.getLLMApiUrl();
      _llmApiKey = await _settingsService.getLLMApiKey();
      _llmModel = await _settingsService.getLLMModel();
      _vlmApiUrl = await _settingsService.getVLMApiUrl();
      _vlmApiKey = await _settingsService.getVLMApiKey();
      _vlmModel = await _settingsService.getVLMModel();
      _plantIdApiKey = await _settingsService.getPlantIdApiKey();
      _weatherApiKey = await _settingsService.getWeatherApiKey();
      _weatherApiUrl = await _settingsService.getWeatherApiUrl();
      _error = null;
    } catch (e) {
      _error = '加载设置失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// 更新植物识别API类型
  Future<void> updatePlantIdentificationApiType(String type) async {
    try {
      await _settingsService.setPlantIdentificationApiType(type);
      _plantIdentificationApiType = type;
      final preset = _getActivePreset();
      if (preset != null) {
        _updateCachedPreset(preset.copyWith(plantApiType: type));
      }
      notifyListeners();
    } catch (e) {
      _error = '更新植物识别API类型失败: $e';
      notifyListeners();
    }
  }

  /// 更新 iNaturalist 设置
  Future<void> updateINaturalistSettings({
    String? apiUrl,
    String? token,
  }) async {
    try {
      if (apiUrl != null) {
        await _settingsService.setINaturalistApiUrl(apiUrl);
        _inaturalistApiUrl = apiUrl;
      }
      if (token != null) {
        await _settingsService.setINaturalistToken(token);
        _inaturalistToken = token;
      }
      final preset = _getActivePreset();
      if (preset != null) {
        _updateCachedPreset(preset.copyWith(
          inaturalistApiUrl: apiUrl ?? preset.inaturalistApiUrl,
          inaturalistToken: token ?? preset.inaturalistToken,
        ));
      }
      notifyListeners();
    } catch (e) {
      _error = '更新 iNaturalist 设置失败: $e';
      notifyListeners();
    }
  }

  /// 更新 LLM API 设置
  Future<void> updateLLMSettings({
    String? apiUrl,
    String? apiKey,
    String? model,
  }) async {
    try {
      if (apiUrl != null) {
        await _settingsService.setLLMApiUrl(apiUrl);
        _llmApiUrl = apiUrl;
      }
      if (apiKey != null) {
        await _settingsService.setLLMApiKey(apiKey);
        _llmApiKey = apiKey;
      }
      if (model != null) {
        await _settingsService.setLLMModel(model);
        _llmModel = model;
      }
      final preset = _getActivePreset();
      if (preset != null) {
        _updateCachedPreset(preset.copyWith(
          llmApiUrl: apiUrl ?? preset.llmApiUrl,
          llmApiKey: apiKey ?? preset.llmApiKey,
          llmModel: model ?? preset.llmModel,
        ));
      }
      notifyListeners();
    } catch (e) {
      _error = '更新 LLM 设置失败: $e';
      notifyListeners();
    }
  }

  /// 更新 VLM API 设置
  Future<void> updateVLMSettings({
    String? apiUrl,
    String? apiKey,
    String? model,
  }) async {
    try {
      if (apiUrl != null) {
        await _settingsService.setVLMApiUrl(apiUrl);
        _vlmApiUrl = apiUrl;
      }
      if (apiKey != null) {
        await _settingsService.setVLMApiKey(apiKey);
        _vlmApiKey = apiKey;
      }
      if (model != null) {
        await _settingsService.setVLMModel(model);
        _vlmModel = model;
      }
      final preset = _getActivePreset();
      if (preset != null) {
        _updateCachedPreset(preset.copyWith(
          vlmApiUrl: apiUrl ?? preset.vlmApiUrl,
          vlmApiKey: apiKey ?? preset.vlmApiKey,
          vlmModel: model ?? preset.vlmModel,
        ));
      }
      notifyListeners();
    } catch (e) {
      _error = '更新 VLM 设置失败: $e';
      notifyListeners();
    }
  }

  /// 更新 Plant.id API 设置
  Future<void> updatePlantIdSettings({String? apiKey}) async {
    try {
      if (apiKey != null) {
        await _settingsService.setPlantIdApiKey(apiKey);
        _plantIdApiKey = apiKey;
      }
      final preset = _getActivePreset();
      if (preset != null) {
        _updateCachedPreset(preset.copyWith(plantIdApiKey: apiKey ?? preset.plantIdApiKey));
      }
      notifyListeners();
    } catch (e) {
      _error = '更新 Plant.id 设置失败: $e';
      notifyListeners();
    }
  }

  /// 更新 Weather API 设置
  Future<void> updateWeatherSettings({
    String? apiKey,
    String? apiUrl,
  }) async {
    try {
      if (apiKey != null) {
        await _settingsService.setWeatherApiKey(apiKey);
        _weatherApiKey = apiKey;
      }
      if (apiUrl != null) {
        await _settingsService.setWeatherApiUrl(apiUrl);
        _weatherApiUrl = apiUrl;
      }
      final preset = _getActivePreset();
      if (preset != null) {
        _updateCachedPreset(preset.copyWith(
          weatherApiKey: apiKey ?? preset.weatherApiKey,
          weatherApiUrl: apiUrl ?? preset.weatherApiUrl,
        ));
      }
      notifyListeners();
    } catch (e) {
      _error = '更新 Weather API 设置失败: $e';
      notifyListeners();
    }
  }

  /// 切换活跃的API预设
  Future<void> setActiveApiPreset(String presetId) async {
    if (_activeApiPresetId == presetId) {
      return;
    }

    try {
      final preset = _apiPresets.firstWhere(
        (item) => item.id == presetId,
        orElse: () => throw Exception('未找到指定的预设'),
      );

      await _settingsService.setActiveApiPresetId(presetId);
      _activeApiPresetId = presetId;
      _applyPresetFields(preset);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = '切换预设失败: $e';
      notifyListeners();
    }
  }

  /// 新增API预设
  Future<void> addApiPreset(String name, {bool cloneFromActive = true}) async {
    final presetName = name.trim().isEmpty ? '新预设' : name.trim();

    try {
      final newId = _generatePresetId();
      final ApiPreset basePreset;

      if (cloneFromActive) {
        final active = _getActivePreset();
        if (active != null) {
          basePreset = active.copyWith(id: newId, name: presetName);
        } else {
          basePreset = ApiPreset.empty(id: newId, name: presetName);
        }
      } else {
        basePreset = ApiPreset.empty(id: newId, name: presetName);
      }

      final updatedList = List<ApiPreset>.from(_apiPresets)..add(basePreset);
      _apiPresets = updatedList;

      await _settingsService.setApiPresets(_apiPresets);
      await _settingsService.setActiveApiPresetId(basePreset.id);

      _activeApiPresetId = basePreset.id;
      _applyPresetFields(basePreset);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = '新增预设失败: $e';
      notifyListeners();
    }
  }

  /// 重命名API预设
  Future<void> renameApiPreset(String presetId, String newName) async {
    final trimmed = newName.trim().isEmpty ? '未命名预设' : newName.trim();

    try {
      final index = _apiPresets.indexWhere((preset) => preset.id == presetId);
      if (index == -1) {
        throw Exception('未找到指定的预设');
      }

      final updatedPreset = _apiPresets[index].copyWith(name: trimmed);
      final updatedList = List<ApiPreset>.from(_apiPresets);
      updatedList[index] = updatedPreset;
      _apiPresets = updatedList;

      await _settingsService.setApiPresets(_apiPresets);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = '重命名预设失败: $e';
      notifyListeners();
    }
  }

  /// 删除API预设
  Future<void> deleteApiPreset(String presetId) async {
    if (_apiPresets.length <= 1) {
      _error = '至少保留一套预设';
      notifyListeners();
      return;
    }

    try {
      final updatedList = _apiPresets.where((preset) => preset.id != presetId).toList();
      if (updatedList.isEmpty) {
        throw Exception('无法删除最后一套预设');
      }

      final bool removedActive = _activeApiPresetId == presetId;
      _apiPresets = updatedList;

      await _settingsService.setApiPresets(_apiPresets);

      if (removedActive) {
        final fallback = _apiPresets.first;
        await _settingsService.setActiveApiPresetId(fallback.id);
        _activeApiPresetId = fallback.id;
        _applyPresetFields(fallback);
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = '删除预设失败: $e';
      notifyListeners();
    }
  }

  /// 更新主题
  Future<void> updateTheme(AppThemeType theme) async {
    try {
      await _settingsService.setThemeType(theme);
      _currentTheme = theme;
      notifyListeners();
    } catch (e) {
      _error = '更新主题失败: $e';
      notifyListeners();
    }
  }

  /// 切换Demo模式
  void toggleDemoMode(bool enabled) {
    _isDemoMode = enabled;
    notifyListeners();
  }

  /// 获取Demo数据
  PlantIdentificationResult getDemoPlantResult() {
    return PlantIdentificationResult(
      species: '龙血树属 百合竹',
      scientificName: 'Dracaena reflexa',
      confidence: 0.93,
      healthAnalysis: '植物整体状态良好，叶片呈细长带状，颜色为深绿色，显示出健康的生长迹象。\n\n叶片颜色为深绿色，整体较为浓密，但部分叶片边缘略显发黄或干枯。叶片细长，呈线状披针形，符合该植物的自然生长特征。部分叶片边缘有轻微卷曲和干枯现象，但整体叶片并未大面积枯萎。\n\n该植物整体形态较为正常，无明显病虫害迹象，枝条分布均匀，植株高度适中，分枝较多，显示出良好的分枝能力。树干挺拔，支撑力较强，表明植株生长稳定。但是枝叶末端干枯，显示出其健康状况并非最佳。',
      careRecommendations: '''{"lighting": "该植物喜散射光，适合放置在明亮但无直射阳光的位置，避免强光直射，以防叶片灼伤。", "watering": "保持土壤微湿，避免积水。建议每周浇水一次，具体频率根据环境湿度调整，确保土壤表面干燥后再浇水。", "temperature": "适宜温度范围为15℃至25℃，避免低温和极端高温。室内环境通常较为干燥，尤其是空调房间，可能导致植物叶片边缘失水，出现干枯现象。", "humidity": "喜欢较高的空气湿度，但也能适应普通室内湿度。可定期喷雾增加湿度，特别是在夏季空调使用期间。", "fertilization": "生长季节（春季至秋季）每月施用一次稀释的液体肥料，冬季减少施肥频率或停止施肥。长期未施肥，植物可能会缺乏必要的养分，导致生长缓慢或叶片状态不佳。", "pruning": "定期修剪枯黄或病弱的叶片，以促进新叶生长和保持植株美观。同时，可以适当修剪过长的枝条，以控制植株高度和形状。"}''',
      imagePath: 'assets/demo/monstera.jpg',
    );
  }

  /// 获取Demo植物的健康状态（基于JSON数据分析）
  String getDemoPlantHealthStatus() {
    // 基于health_analysis内容：
    // "植物整体状态良好" + "显示出健康的生长迹象" 但有 "部分叶片边缘略显发黄或干枯" + "枝叶末端干枯"
    // 综合判断为"良好"状态
    return '良好';
  }

  /// 验证设置完整性
  Future<bool> areSettingsComplete() async {
    return await _settingsService.areSettingsComplete();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  ApiPreset? _getActivePreset() {
    if (_apiPresets.isEmpty) {
      return null;
    }

    if (_activeApiPresetId == null) {
      return _apiPresets.first;
    }

    for (final preset in _apiPresets) {
      if (preset.id == _activeApiPresetId) {
        return preset;
      }
    }

    return _apiPresets.first;
  }

  void _updateCachedPreset(ApiPreset updated) {
    final index = _apiPresets.indexWhere((preset) => preset.id == updated.id);
    if (index == -1) {
      return;
    }

    final updatedList = List<ApiPreset>.from(_apiPresets);
    updatedList[index] = updated;
    _apiPresets = updatedList;
  }

  void _applyPresetFields(ApiPreset preset) {
    _plantIdentificationApiType = preset.plantApiType;
    _inaturalistApiUrl = preset.inaturalistApiUrl;
    _inaturalistToken = preset.inaturalistToken;
    _plantIdApiKey = preset.plantIdApiKey;
    _llmApiUrl = preset.llmApiUrl;
    _llmApiKey = preset.llmApiKey;
    _llmModel = preset.llmModel;
    _vlmApiUrl = preset.vlmApiUrl;
    _vlmApiKey = preset.vlmApiKey;
    _vlmModel = preset.vlmModel;
    _weatherApiUrl = preset.weatherApiUrl;
    _weatherApiKey = preset.weatherApiKey;
  }

  String _generatePresetId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = _random.nextInt(1 << 20);
    return 'preset_${timestamp}_$suffix';
  }

  /// 验证LLM API可用性
  Future<Map<String, dynamic>> testLLMApi({
    String? apiUrl,
    String? apiKey,
    String? model,
  }) async {
    final testUrl = apiUrl ?? _llmApiUrl;
    final testKey = apiKey ?? _llmApiKey;
    final testModel = model ?? _llmModel;

    if (testUrl.isEmpty || testKey.isEmpty || testModel.isEmpty) {
      return {
        'success': false,
        'message': '请填写完整的LLM API配置信息',
      };
    }

    try {
      final response = await _dio.post(
        testUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $testKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
        data: {
          'model': testModel,
          'messages': [
            {
              'role': 'user',
              'content': 'Hello, this is a test message.',
            },
          ],
          'max_tokens': 10,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'LLM API连接成功',
          'response': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'API返回错误: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'LLM API测试失败: ';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage += '连接超时';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage += '接收超时';
      } else if (e.response != null) {
        errorMessage += '状态码: ${e.response!.statusCode}, ${e.response!.data}';
      } else {
        errorMessage += e.message ?? '未知错误';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'LLM API测试失败: $e',
      };
    }
  }

  /// 验证VLM API可用性
  Future<Map<String, dynamic>> testVLMApi({
    String? apiUrl,
    String? apiKey,
    String? model,
  }) async {
    final testUrl = apiUrl ?? _vlmApiUrl;
    final testKey = apiKey ?? _vlmApiKey;
    final testModel = model ?? _vlmModel;

    if (testUrl.isEmpty || testKey.isEmpty || testModel.isEmpty) {
      return {
        'success': false,
        'message': '请填写完整的VLM API配置信息',
      };
    }

    try {
      final response = await _dio.post(
        testUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $testKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
        data: {
          'model': testModel,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'This is a test message for vision model.',
                },
              ],
            },
          ],
          'max_tokens': 10,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'VLM API连接成功',
          'response': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'API返回错误: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'VLM API测试失败: ';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage += '连接超时';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage += '接收超时';
      } else if (e.response != null) {
        errorMessage += '状态码: ${e.response!.statusCode}, ${e.response!.data}';
      } else {
        errorMessage += e.message ?? '未知错误';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'VLM API测试失败: $e',
      };
    }
  }
}
