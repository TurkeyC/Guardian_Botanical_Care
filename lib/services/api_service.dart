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

    // 添加重试拦截器
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      logPrint: print,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));
  }

  // 公开访问Dio实例的方法
  Dio get dio => _dio;

  // 辅助方法：正确构建API URL
  String buildApiUrl(String baseUrl, String endpoint) {
    // 确保基础URL不以斜杠结尾
    String cleanBaseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
    // 确保端点以斜杠开头
    String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$cleanBaseUrl$cleanEndpoint';
  }
}

// 重试拦截器
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String message)? logPrint;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
    this.logPrint,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _shouldRetry(err);

    if (shouldRetry && err.requestOptions.extra['retryCount'] != null) {
      final retryCount = err.requestOptions.extra['retryCount'] as int;

      if (retryCount < retries) {
        logPrint?.call('重试请求 ${retryCount + 1}/$retries: ${err.requestOptions.uri}');

        await Future.delayed(retryDelays[retryCount]);

        final options = err.requestOptions.copyWith(
          extra: {...err.requestOptions.extra, 'retryCount': retryCount + 1},
        );

        try {
          final response = await dio.fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          // 继续处理错误
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.unknown ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
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
    required String apiUrl,  // 现在期望完整的API地址，如 https://api.openai.com/v1/chat/completions
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

      // 直接使用用户提供的完整API地址，不再添加路径
      final response = await _apiService.dio.post(
        apiUrl,
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          extra: {'retryCount': 0},
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
      print('API请求错误: $e');
      if (e is DioException) {
        print('错误类型: ${e.type}');
        print('请求URL: ${e.requestOptions.uri}');
      }
      print('VLM 植物识别调用失败: $e');
      return null;
    }
  }

  /// 生成养护建议
  Future<String?> generateCareAdvice({
    required String plantSpecies,
    required String healthAnalysis,
    required String apiUrl,  // 现在期望完整的API地址
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

      // 直接使用用户提供的完整API地址，不再添加路径
      final response = await _apiService.dio.post(
        apiUrl,
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          extra: {'retryCount': 0},
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
      print('API请求错误: $e');
      if (e is DioException) {
        print('错误类型: ${e.type}');
        print('请求URL: ${e.requestOptions.uri}');
      }
      print('OpenAI 养护建议生成失败: $e');
      return null;
    }
  }
}

class PlantIdentificationService {
  final ApiService _apiService = ApiService.instance;

  /// 统一的植物识别接口
  Future<PlantIdentificationResult?> identifyPlant({
    required File imageFile,
    required String apiType,
    required Map<String, String> apiConfig,
  }) async {
    switch (apiType) {
      case 'inaturalist':
        return await _identifyWithINaturalist(imageFile, apiConfig);
      case 'plantid':
        return await _identifyWithPlantId(imageFile, apiConfig);
      case 'vlm':
        return await _identifyWithVLM(imageFile, apiConfig);
      default:
        throw Exception('不支持的植物识别API类型: $apiType');
    }
  }

  /// 使用iNaturalist API识别
  Future<PlantIdentificationResult?> _identifyWithINaturalist(
    File imageFile,
    Map<String, String> config,
  ) async {
    try {
      final iNaturalistService = INaturalistApiService();
      final result = await iNaturalistService.identifyPlant(
        imageFile: imageFile,
        apiUrl: config['apiUrl']!,
        token: config['token']!,
      );

      if (result == null || result.results.isEmpty) {
        return null;
      }

      final bestResult = result.results.first;
      final plantName = bestResult.taxon.preferredCommonName ?? bestResult.taxon.name;

      return PlantIdentificationResult(
        species: plantName,
        scientificName: bestResult.taxon.name,
        confidence: bestResult.score,
        healthAnalysis: '通过iNaturalist识别，需要进一步健康分析',
        careRecommendations: '请使用LLM API获取详细养护建议',
        imagePath: imageFile.path,
      );
    } catch (e) {
      print('iNaturalist识别失败: $e');
      return null;
    }
  }

  /// 使用Plant.id API识别
  Future<PlantIdentificationResult?> _identifyWithPlantId(
    File imageFile,
    Map<String, String> config,
  ) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      final requestData = {
        'images': [imageBase64],
        'modifiers': ['crops_fast', 'similar_images'],
        'plant_details': ['common_names', 'url', 'description'],
      };

      final response = await _apiService.dio.post(
        'https://api.plant.id/v2/identify',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Api-Key': config['apiKey']!,
          },
        ),
      );

      if (response.statusCode == 200 && response.data['suggestions'] != null) {
        final suggestions = response.data['suggestions'] as List;
        if (suggestions.isNotEmpty) {
          final bestSuggestion = suggestions.first;
          final plantDetails = bestSuggestion['plant_details'];

          return PlantIdentificationResult(
            species: plantDetails['common_names']?.first ?? '未知植物',
            scientificName: bestSuggestion['plant_name'] ?? '',
            confidence: (bestSuggestion['probability'] ?? 0.0).toDouble(),
            healthAnalysis: '通过Plant.id识别，需要进一步健康分析',
            careRecommendations: '请使用LLM API获取详细养护建议',
            imagePath: imageFile.path,
          );
        }
      }

      return null;
    } catch (e) {
      print('Plant.id识别失败: $e');
      return null;
    }
  }

  /// 使用VLM API识别
  Future<PlantIdentificationResult?> _identifyWithVLM(
    File imageFile,
    Map<String, String> config,
  ) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      print('VLM API配置: $config'); // 调试日志
      print('图片大小: ${imageBytes.length} 字节'); // 调试日志

      final prompt = '''
请分析这张植物图片，提供以下信息。请严格按照JSON格式返回，不要添加任何其他文字：

{
  "species": "植物的中文常见名称",
  "scientific_name": "植物的拉丁学名",
  "confidence": "0.00到0.95之间的随机数字(保留两位小数)，表示识别置信度",
  "health_analysis": "植物的健康状况详细分析，包括叶片状态、生长情况等",
  "care_recommendations": {
    "lighting": "光照需求建议",
    "watering": "浇水频率和方法",
    "temperature": "适宜的温度范围",
    "humidity": "湿度要求",
    "fertilization": "施肥建议",
    "pruning": "修剪和维护建议"
  }
}

请确保返回的是有效的JSON格式。
''';

      // 限制图片大小，避免请求过大
      String finalImageBase64 = imageBase64;
      if (imageBytes.length > 2 * 1024 * 1024) { // 如果图片大于2MB
        print('图片过大，需要压缩处理');
        // TODO: 这里可以添加图片压缩逻辑
      }

      // 检测API类型并使用相应格式
      Map<String, dynamic> requestData;

      if (config['apiUrl']!.contains('bigmodel.cn')) {
        // 智谱AI GLM格式 - 根据官方文档调整
        requestData = {
          'model': config['model']!,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': prompt,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$finalImageBase64',
                  },
                },
              ],
            },
          ],
          // 智谱AI使用不同的参数名
          'top_p': 0.7,
          'temperature': 0.95,
        };
      } else {
        // OpenAI格式
        requestData = {
          'model': config['model']!,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': prompt,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$finalImageBase64',
                    'detail': 'low',
                  },
                },
              ],
            },
          ],
          'max_tokens': 1500,
          'temperature': 0.1,
        };
      }

      print('VLM请求URL: ${config['apiUrl']}'); // 调试日志
      print('VLM请求数据: ${jsonEncode(requestData).substring(0, 200)}...'); // 只打印前200字符

      // 直接使用用户提供的完整API地址，不再添加路径
      final response = await _apiService.dio.post(
        config['apiUrl']!,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config['apiKey']!}',
            'Content-Type': 'application/json',
          },
          extra: {'retryCount': 0},
          validateStatus: (status) {
            // 允许所有状态码通过，我们手动处理错误
            return status != null;
          },
        ),
      );

      print('VLM响应状态码: ${response.statusCode}'); // 调试日志
      print('VLM响应数据: ${response.data}'); // 调试日志

      if (response.statusCode == 200) {
        try {
          final responseData = response.data;
          if (responseData != null && responseData['choices'] != null) {
            final choices = responseData['choices'] as List;
            if (choices.isNotEmpty) {
              final content = choices.first['message']['content'] as String;
              print('VLM原始响应: $content'); // 调试日志

              // 尝试解析JSON响应
              try {
                // 提取JSON内容，支持多种格式
                String jsonString = content;

                // 如果内容包含```json代码块，提取其中的JSON
                final codeBlockMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(content);
                if (codeBlockMatch != null) {
                  jsonString = codeBlockMatch.group(1)!.trim();
                } else {
                  // 尝试提取花括号内的JSON
                  final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
                  if (jsonMatch != null) {
                    jsonString = jsonMatch.group(0)!;
                  }
                }

                final jsonData = jsonDecode(jsonString);
                print('解析的JSON数据: $jsonData'); // 调试日志

                // 处理care_recommendations字段
                String careRecommendationsString;
                if (jsonData['care_recommendations'] is Map) {
                  // 如果是对象，将其转换为JSON字符串存储
                  careRecommendationsString = jsonEncode(jsonData['care_recommendations']);
                } else if (jsonData['care_recommendations'] is String) {
                  careRecommendationsString = jsonData['care_recommendations'];
                } else {
                  careRecommendationsString = '暂无详细养护建议';
                }

                return PlantIdentificationResult(
                  species: jsonData['species']?.toString() ?? '未知植物',
                  scientificName: jsonData['scientific_name']?.toString() ?? '',
                  confidence: _parseConfidence(jsonData['confidence']),
                  healthAnalysis: jsonData['health_analysis']?.toString() ?? '无法分析健康状况',
                  careRecommendations: careRecommendationsString,
                  imagePath: imageFile.path,
                );
              } catch (e) {
                print('解析VLM JSON响应失败: $e');
                print('原始内容: $content');

                // JSON解析失败，尝试文本解析
                return _parseVLMTextResponse(content, imageFile.path);
              }
            }
          }
        } catch (e) {
          print('处理VLM响应失败: $e');
        }
      } else {
        // 处理错误响应
        print('VLM API错误 ${response.statusCode}: ${response.data}');

        // 尝试解析错误信息
        String errorMessage = 'API请求失败';
        if (response.data != null) {
          try {
            if (response.data is Map && response.data['error'] != null) {
              errorMessage = response.data['error']['message'] ?? errorMessage;
            } else if (response.data is String) {
              errorMessage = response.data;
            }
          } catch (e) {
            print('解析错误响应失败: $e');
          }
        }

        throw Exception('VLM API错误 (${response.statusCode}): $errorMessage');
      }

      return null;
    } catch (e) {
      print('VLM识别失败: $e');

      // 根据错误类型提供更具体的错误信息
      if (e is DioException) {
        print('Dio错误类型: ${e.type}');
        print('请求选项: ${e.requestOptions.uri}');
        print('响应状态码: ${e.response?.statusCode}');
        print('响应数据: ${e.response?.data}');

        // 提供用户友好的错误信息
        String userFriendlyError = 'VLM识别失败';
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            userFriendlyError = '网络连接超时，请检查网络设置';
            break;
          case DioExceptionType.badResponse:
            if (e.response?.statusCode == 400) {
              userFriendlyError = '请求参数错误，请检查API配置';
            } else if (e.response?.statusCode == 401) {
              userFriendlyError = 'API密钥无效，请检查设置';
            } else if (e.response?.statusCode == 403) {
              userFriendlyError = 'API访问被拒绝，请检查权限';
            } else if (e.response?.statusCode == 429) {
              userFriendlyError = 'API调用频率过高，请稍后重试';
            } else {
              userFriendlyError = 'API服务异常 (${e.response?.statusCode})';
            }
            break;
          case DioExceptionType.unknown:
            userFriendlyError = '网络连接失败，请检查网络和API地址';
            break;
          default:
            userFriendlyError = 'VLM识别服务暂时不可用';
        }

        throw Exception(userFriendlyError);
      }

      return null;
    }
  }

  /// 解析置信度值
  double _parseConfidence(dynamic confidence) {
    if (confidence == null) return 0.8;

    if (confidence is num) {
      double value = confidence.toDouble();
      // 如果值大于1，假设是百分比，转换为0-1范围
      if (value > 1) {
        value = value / 100;
      }
      return value.clamp(0.0, 1.0);
    }

    if (confidence is String) {
      try {
        double value = double.parse(confidence.replaceAll('%', ''));
        if (value > 1) {
          value = value / 100;
        }
        return value.clamp(0.0, 1.0);
      } catch (e) {
        return 0.8;
      }
    }

    return 0.8;
  }

  /// 当JSON解析失败时，尝试从文本中提取信息
  PlantIdentificationResult _parseVLMTextResponse(String content, String imagePath) {
    // 尝试从文本中提取植物名称
    String species = '通过VLM识别的植物';
    String scientificName = '';
    double confidence = 0.8;

    // 简单的文本解析逻辑
    final lines = content.split('\n');
    for (final line in lines) {
      if (line.contains('植物名称') || line.contains('种类') || line.contains('品种')) {
        final match = RegExp(r'[:：]\s*(.+)').firstMatch(line);
        if (match != null) {
          species = match.group(1)!.trim();
        }
      } else if (line.contains('学名') || line.contains('拉丁名')) {
        final match = RegExp(r'[:：]\s*(.+)').firstMatch(line);
        if (match != null) {
          scientificName = match.group(1)!.trim();
        }
      } else if (line.contains('置信度') || line.contains('确信度')) {
        final match = RegExp(r'([\d.]+)').firstMatch(line);
        if (match != null) {
          confidence = _parseConfidence(match.group(1));
        }
      }
    }

    return PlantIdentificationResult(
      species: species,
      scientificName: scientificName,
      confidence: confidence,
      healthAnalysis: content,
      careRecommendations: content,
      imagePath: imagePath,
    );
  }
}

class WeatherService {
  final ApiService _apiService = ApiService.instance;

  /// 获取天气信息
  Future<WeatherInfo?> getWeatherInfo({
    required double latitude,
    required double longitude,
    required String apiKey,
    required String apiUrl,
  }) async {
    try {
      final fullUrl = _apiService.buildApiUrl(apiUrl, '/current.json');

      final response = await _apiService.dio.get(
        fullUrl,
        queryParameters: {
          'key': apiKey,
          'q': '$latitude,$longitude',
          'aqi': 'no',
        },
        options: Options(
          extra: {'retryCount': 0},
        ),
      );

      if (response.statusCode == 200) {
        return WeatherInfo.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('获取天气信息失败: $e');
      return null;
    }
  }
}
