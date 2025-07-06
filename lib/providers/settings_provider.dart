import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';
import '../themes/app_themes.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

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
}
