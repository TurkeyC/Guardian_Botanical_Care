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

import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';
import '../themes/app_themes.dart';
import 'package:dio/dio.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  final Dio _dio = Dio();

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

  /// 初始化设置
  Future<void> loadSettings() async {
    _setLoading(true);
    try {
      _currentTheme = await _settingsService.getThemeType();
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
      notifyListeners();
    } catch (e) {
      _error = '更新 Weather API 设置失败: $e';
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
