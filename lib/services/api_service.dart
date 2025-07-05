import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../models/plant.dart';

class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();

  ApiService._();

  late Dio _dio;

  void init() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }
}

class INaturalistApiService {
  final ApiService _apiService = ApiService.instance;

  /// 调用iNaturalist API识别植物
  Future<INaturalistResponse?> identifyPlant({
    required File imageFile,
    required String apiUrl,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/v1/identifications')
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path)
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> json = jsonDecode(responseBody);
        return INaturalistResponse.fromJson(json);
      } else {
        throw Exception('识别失败: ${response.statusCode}');
      }
    } catch (e) {
      print('iNaturalist API 调用失败: $e');
      return null;
    }
  }
}

class OpenAIApiService {
  final ApiService _apiService = ApiService.instance;

  /// 分析植物健康状态
  Future<String?> analyzeImage({
    required String imageBase64,
    required String apiUrl,
    required String apiKey,
    String model = 'gpt-4-vision-preview',
  }) async {
    try {
      final request = OpenAIRequest(
        model: model,
        messages: [
          Message(
            role: 'user',
            content: [
              Content(type: 'text', text: '''
请分析这张植物图片的健康状况，包括：
1. 整体健康状态（健康/一般/不健康）
2. 是否有病虫害迹象
3. 叶片状态（颜色、形状、是否枯萎等）
4. 可能存在的问题和原因
请用中文回答，格式清晰。
'''),
              Content(
                type: 'image_url',
                imageUrl: ImageUrl(url: 'data:image/jpeg;base64,$imageBase64'),
              ),
            ],
          ),
        ],
        maxTokens: 1000,
      );

      final response = await _apiService._dio.post(
        '$apiUrl/v1/chat/completions',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final openAIResponse = OpenAIResponse.fromJson(response.data);
        if (openAIResponse.choices.isNotEmpty) {
          return openAIResponse.choices.first.message.content;
        }
      }

      throw Exception('健康分析失败: ${response.statusCode}');
    } catch (e) {
      print('OpenAI 健康分析调用失败: $e');
      return null;
    }
  }

  /// 生成养护建议
  Future<String?> generateCareAdvice({
    required String plantSpecies,
    required String healthAnalysis,
    required String apiUrl,
    required String apiKey,
    String model = 'gpt-4',
  }) async {
    try {
      final request = OpenAIRequest(
        model: model,
        messages: [
          Message(
            role: 'user',
            content: '''
基于以下信息，请提供详细的植物养护建议：

植物品种：$plantSpecies
健康状况分析：$healthAnalysis

请提供以下方面的具体建议：
1. 浇水频率和方法
2. 光照需求
3. 施肥建议
4. 温湿度要求
5. 常见问题预防
6. 季节性护理要点

请用中文回答，内容实用且易于理解。
''',
          ),
        ],
        maxTokens: 1500,
      );

      final response = await _apiService._dio.post(
        '$apiUrl/v1/chat/completions',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final openAIResponse = OpenAIResponse.fromJson(response.data);
        if (openAIResponse.choices.isNotEmpty) {
          return openAIResponse.choices.first.message.content;
        }
      }

      throw Exception('养护建议生成失败: ${response.statusCode}');
    } catch (e) {
      print('OpenAI 养护建议生成失败: $e');
      return null;
    }
  }
}
