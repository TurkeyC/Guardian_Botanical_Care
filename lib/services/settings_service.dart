import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant.dart';

class SettingsService {
  static const String _inaturalistApiUrlKey = 'inaturalist_api_url';
  static const String _inaturalistTokenKey = 'inaturalist_token';
  static const String _openaiApiUrlKey = 'openai_api_url';
  static const String _openaiApiKeyKey = 'openai_api_key';
  static const String _visionModelKey = 'vision_model';
  static const String _textModelKey = 'text_model';

  // iNaturalist 设置
  Future<String?> getINaturalistApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_inaturalistApiUrlKey) ?? 'https://api.inaturalist.org';
  }

  Future<void> setINaturalistApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_inaturalistApiUrlKey, url);
  }

  Future<String?> getINaturalistToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_inaturalistTokenKey);
  }

  Future<void> setINaturalistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_inaturalistTokenKey, token);
  }

  // OpenAI 设置
  Future<String?> getOpenAIApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_openaiApiUrlKey) ?? 'https://api.openai.com';
  }

  Future<void> setOpenAIApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_openaiApiUrlKey, url);
  }

  Future<String?> getOpenAIApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_openaiApiKeyKey);
  }

  Future<void> setOpenAIApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_openaiApiKeyKey, apiKey);
  }

  // 模型设置
  Future<String> getVisionModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_visionModelKey) ?? 'gpt-4-vision-preview';
  }

  Future<void> setVisionModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_visionModelKey, model);
  }

  Future<String> getTextModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_textModelKey) ?? 'gpt-4';
  }

  Future<void> setTextModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_textModelKey, model);
  }

  // 验证设置完整性
  Future<bool> areSettingsComplete() async {
    final inaturalistToken = await getINaturalistToken();
    final openaiApiKey = await getOpenAIApiKey();

    return inaturalistToken?.isNotEmpty == true &&
           openaiApiKey?.isNotEmpty == true;
  }
}
