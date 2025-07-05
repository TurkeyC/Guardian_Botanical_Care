import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  // iNaturalist 设置
  String _inaturalistApiUrl = 'https://api.inaturalist.org';
  String _inaturalistToken = '';

  // OpenAI 设置
  String _openaiApiUrl = 'https://api.openai.com';
  String _openaiApiKey = '';

  // 模型设置
  String _visionModel = 'gpt-4-vision-preview';
  String _textModel = 'gpt-4';

  bool _isLoading = false;
  String? _error;

  // Getters
  String get inaturalistApiUrl => _inaturalistApiUrl;
  String get inaturalistToken => _inaturalistToken;
  String get openaiApiUrl => _openaiApiUrl;
  String get openaiApiKey => _openaiApiKey;
  String get visionModel => _visionModel;
  String get textModel => _textModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 初始化设置
  Future<void> loadSettings() async {
    _setLoading(true);
    try {
      _inaturalistApiUrl = await _settingsService.getINaturalistApiUrl() ?? 'https://api.inaturalist.org';
      _inaturalistToken = await _settingsService.getINaturalistToken() ?? '';
      _openaiApiUrl = await _settingsService.getOpenAIApiUrl() ?? 'https://api.openai.com';
      _openaiApiKey = await _settingsService.getOpenAIApiKey() ?? '';
      _visionModel = await _settingsService.getVisionModel();
      _textModel = await _settingsService.getTextModel();
      _error = null;
    } catch (e) {
      _error = '加载设置失败: $e';
    } finally {
      _setLoading(false);
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

  /// 更新 OpenAI 设置
  Future<void> updateOpenAISettings({
    String? apiUrl,
    String? apiKey,
  }) async {
    try {
      if (apiUrl != null) {
        await _settingsService.setOpenAIApiUrl(apiUrl);
        _openaiApiUrl = apiUrl;
      }
      if (apiKey != null) {
        await _settingsService.setOpenAIApiKey(apiKey);
        _openaiApiKey = apiKey;
      }
      notifyListeners();
    } catch (e) {
      _error = '更新 OpenAI 设置失败: $e';
      notifyListeners();
    }
  }

  /// 更新模型设置
  Future<void> updateModelSettings({
    String? visionModel,
    String? textModel,
  }) async {
    try {
      if (visionModel != null) {
        await _settingsService.setVisionModel(visionModel);
        _visionModel = visionModel;
      }
      if (textModel != null) {
        await _settingsService.setTextModel(textModel);
        _textModel = textModel;
      }
      notifyListeners();
    } catch (e) {
      _error = '更新模型设置失败: $e';
      notifyListeners();
    }
  }

  /// 检查设置是否完整
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
