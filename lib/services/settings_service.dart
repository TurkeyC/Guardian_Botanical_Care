import 'package:shared_preferences/shared_preferences.dart';
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

  // 植物识别API类型 (inaturalist, plantid, vlm)
  Future<String> getPlantIdentificationApiType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_plantIdentificationApiTypeKey) ?? 'inaturalist';
  }

  Future<void> setPlantIdentificationApiType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_plantIdentificationApiTypeKey, type);
  }

  // iNaturalist 设置
  Future<String> getINaturalistApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_inaturalistApiUrlKey) ?? 'https://api.inaturalist.org';
  }

  Future<void> setINaturalistApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_inaturalistApiUrlKey, url);
  }

  Future<String> getINaturalistToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_inaturalistTokenKey) ?? '';
  }

  Future<void> setINaturalistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_inaturalistTokenKey, token);
  }

  // LLM API 设置
  Future<String> getLLMApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_llmApiUrlKey) ?? 'https://api.openai.com';
  }

  Future<void> setLLMApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_llmApiUrlKey, url);
  }

  Future<String> getLLMApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_llmApiKeyKey) ?? '';
  }

  Future<void> setLLMApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_llmApiKeyKey, apiKey);
  }

  Future<String> getLLMModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_llmModelKey) ?? 'gpt-4';
  }

  Future<void> setLLMModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_llmModelKey, model);
  }

  // VLM API 设置
  Future<String> getVLMApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_vlmApiUrlKey) ?? 'https://api.openai.com';
  }

  Future<void> setVLMApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vlmApiUrlKey, url);
  }

  Future<String> getVLMApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_vlmApiKeyKey) ?? '';
  }

  Future<void> setVLMApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vlmApiKeyKey, apiKey);
  }

  Future<String> getVLMModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_vlmModelKey) ?? 'gpt-4-vision-preview';
  }

  Future<void> setVLMModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vlmModelKey, model);
  }

  // Plant.id API 设置
  Future<String> getPlantIdApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_plantIdApiKeyKey) ?? '';
  }

  Future<void> setPlantIdApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_plantIdApiKeyKey, apiKey);
  }

  // Weather API 设置
  Future<String> getWeatherApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_weatherApiKeyKey) ?? '';
  }

  Future<void> setWeatherApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weatherApiKeyKey, apiKey);
  }

  Future<String> getWeatherApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_weatherApiUrlKey) ?? 'https://api.weatherapi.com/v1';
  }

  Future<void> setWeatherApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weatherApiUrlKey, url);
  }

  // 主题相关方法
  Future<AppThemeType> getThemeType() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeTypeKey) ?? 'minimal';
    return themeString == 'dynamic' ? AppThemeType.dynamic : AppThemeType.minimal;
  }

  Future<void> setThemeType(AppThemeType themeType) async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = themeType == AppThemeType.dynamic ? 'dynamic' : 'minimal';
    await prefs.setString(_themeTypeKey, themeString);
  }

  // 验证设置完整性
  Future<bool> areSettingsComplete() async {
    final apiType = await getPlantIdentificationApiType();
    final weatherApiKey = await getWeatherApiKey();

    // 天气API是必需的
    if (weatherApiKey.isEmpty) return false;

    switch (apiType) {
      case 'inaturalist':
        final token = await getINaturalistToken();
        return token.isNotEmpty;
      case 'plantid':
        final apiKey = await getPlantIdApiKey();
        return apiKey.isNotEmpty;
      case 'vlm':
        final vlmApiKey = await getVLMApiKey();
        final llmApiKey = await getLLMApiKey();
        return vlmApiKey.isNotEmpty && llmApiKey.isNotEmpty;
      default:
        return false;
    }
  }
}
