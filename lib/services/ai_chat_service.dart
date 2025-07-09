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
import 'package:dio/dio.dart';
import '../providers/settings_provider.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AiChatService {
  static AiChatService? _instance;
  static AiChatService get instance => _instance ??= AiChatService._();

  AiChatService._();

  late Dio _dio;
  final List<ChatMessage> _chatHistory = [];
  SettingsProvider? _settingsProvider;

  void init({SettingsProvider? settingsProvider}) {
    _settingsProvider = settingsProvider;
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  List<ChatMessage> get chatHistory => List.unmodifiable(_chatHistory);

  void clearHistory() {
    _chatHistory.clear();
  }

  Future<String> sendMessage(String message) async {
    try {
      // 优先使用配置的LLM API，如果配置不完整则使用模拟响应
      if (_settingsProvider != null && _isLLMConfigured()) {
        return await _callConfiguredLLMAPI(message);
      } else {
        // 回退到模拟响应
        return await _simulateAIResponse(message);
      }
    } catch (e) {
      print('AI服务调用失败: $e');

      // 如果API调用失败，尝试使用模拟响应作为备选
      try {
        return await _simulateAIResponse(message);
      } catch (fallbackError) {
        throw Exception('AI服务暂时不可用，请稍后重试：$e');
      }
    }
  }

  /// 检查LLM是否已正确配置
  bool _isLLMConfigured() {
    if (_settingsProvider == null) return false;

    final apiUrl = _settingsProvider!.llmApiUrl;
    final apiKey = _settingsProvider!.llmApiKey;
    final model = _settingsProvider!.llmModel;

    return apiUrl.isNotEmpty && apiKey.isNotEmpty && model.isNotEmpty;
  }

  /// 使用配置的LLM API进行调用
  Future<String> _callConfiguredLLMAPI(String message) async {
    if (_settingsProvider == null) {
      throw Exception('设置提供程序未初始化');
    }

    // 构建对话历史
    final messages = [
      {
        "role": "system",
        "content": "你是一位专业的植物养护专家，专注于为用户解答各种植物相关的问题。你的回答应该专业、准确、实用，并且语言友好亲切。请用中文回答问题。"
      },
      ..._chatHistory.where((msg) => !msg.isLoading).map((msg) => {
        "role": msg.isUser ? "user" : "assistant",
        "content": msg.content,
      }).toList(),
      {
        "role": "user",
        "content": message,
      }
    ];

    try {
      final apiUrl = _settingsProvider!.llmApiUrl;
      final apiKey = _settingsProvider!.llmApiKey;
      final model = _settingsProvider!.llmModel;

      print('调用配置的LLM API: $apiUrl');
      print('使用模型: $model');

      // 构建请求数据
      Map<String, dynamic> requestData;

      // 检测API类型并使用相应格式
      if (apiUrl.contains('bigmodel.cn')) {
        // 智谱AI GLM格式
        requestData = {
          'model': model,
          'messages': messages,
          'top_p': 0.7,
          'temperature': 0.95,
          'stream': false,
        };
      } else if (apiUrl.contains('dashscope.aliyuncs.com')) {
        // 阿里云通义千问格式
        requestData = {
          'model': model,
          'input': {
            'messages': messages,
          },
          'parameters': {
            'result_format': 'message',
            'temperature': 0.7,
            'top_p': 0.8,
          },
        };
      } else if (apiUrl.contains('aip.baidubce.com')) {
        // 百度文心一言格式
        requestData = {
          'messages': messages,
          'temperature': 0.7,
          'top_p': 0.8,
          'penalty_score': 1.0,
          'stream': false,
        };
      } else {
        // 默认使用OpenAI格式
        requestData = {
          'model': model,
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.7,
          'stream': false,
        };
      }

      // 发送请求
      final response = await _dio.post(
        apiUrl,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null,
        ),
      );

      print('LLM API响应状态码: ${response.statusCode}');
      print('LLM API响应数据: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // 解析不同API的响应格式
        String? content;

        if (apiUrl.contains('dashscope.aliyuncs.com')) {
          // 阿里云通义千问响应格式
          content = responseData['output']?['choices']?[0]?['message']?['content'];
        } else if (apiUrl.contains('aip.baidubce.com')) {
          // 百度文心一言响应格式
          content = responseData['result'];
        } else {
          // OpenAI格式 (包括智谱AI等兼容格式)
          content = responseData['choices']?[0]?['message']?['content'];
        }

        if (content != null && content.isNotEmpty) {
          return content;
        } else {
          throw Exception('API返回了空响应');
        }
      } else {
        // 处理错误响应
        String errorMessage = 'API请求失败 (${response.statusCode})';

        if (response.data != null) {
          try {
            if (response.data is Map) {
              final errorData = response.data as Map<String, dynamic>;
              if (errorData['error'] != null) {
                if (errorData['error'] is Map) {
                  errorMessage = errorData['error']['message'] ?? errorMessage;
                } else {
                  errorMessage = errorData['error'].toString();
                }
              } else if (errorData['message'] != null) {
                errorMessage = errorData['message'].toString();
              }
            }
          } catch (e) {
            print('解析错误响应失败: $e');
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('LLM API调用失败: $e');

      if (e is DioException) {
        String userFriendlyError = '网络请求失败';

        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            userFriendlyError = '请求超时，请检查网络连接';
            break;
          case DioExceptionType.badResponse:
            if (e.response?.statusCode == 401) {
              userFriendlyError = 'API密钥无效，请检查设置';
            } else if (e.response?.statusCode == 403) {
              userFriendlyError = 'API访问被拒绝，请检查权限';
            } else if (e.response?.statusCode == 429) {
              userFriendlyError = 'API调用频率过高，请稍后重试';
            } else if (e.response?.statusCode == 400) {
              userFriendlyError = '请求参数错误，请检查API配置';
            } else {
              userFriendlyError = 'API服务异常 (${e.response?.statusCode})';
            }
            break;
          case DioExceptionType.unknown:
            userFriendlyError = '网络连接失败，请检查网络和API地址';
            break;
          default:
            userFriendlyError = 'LLM服务暂时不可用';
        }

        throw Exception(userFriendlyError);
      }

      rethrow;
    }
  }

  Future<String> _callOpenAIAPI(String message) async {
    // 保留原有的方法以防需要
    return await _callConfiguredLLMAPI(message);
  }

  // 模拟AI响应（用于演示）
  Future<String> _simulateAIResponse(String message) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 2));

    // 基于关键词的简单响应逻辑
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('浇水') || lowerMessage.contains('水分')) {
      return '关于植物浇水，我建议您：\n\n1. 观察土壤湿度，用手指插入土壤2-3厘米深度检查\n2. 大多数室内植物喜欢土壤微湿但不积水\n3. 浇水时要浇透，让水从排水孔流出\n4. 不同季节浇水频率不同，冬季需要减少浇水\n\n请告诉我您具体养的是什么植物，我可以给出更精确的建议！';
    } else if (lowerMessage.contains('施肥') || lowerMessage.contains('营养')) {
      return '植物施肥的关键要点：\n\n1. 生长期（春夏）每2-4周施肥一次\n2. 休眠期（秋冬）减少或停止施肥\n3. 选择适合的肥料类型：液体肥、缓释肥或有机肥\n4. 遵循"薄肥勤施"原则，浓度宁低勿高\n5. 施肥前确保土壤湿润\n\n您的植物出现了什么症状吗？我可以帮您判断是否需要施肥。';
    } else if (lowerMessage.contains('黄叶') || lowerMessage.contains('叶子黄')) {
      return '叶子发黄的常见原因及解决方案：\n\n1. **浇水过多**：停止浇水，改善排水\n2. **浇水不足**：增加浇水频率\n3. **光照不足**：移至光线更好的位置\n4. **养分缺乏**：适量施肥\n5. **自然老化**：老叶发黄是正常现象\n6. **温度骤变**：保持环境温度稳定\n\n请描述一下黄叶的位置和程度，我可以帮您更准确地诊断问题！';
    } else if (lowerMessage.contains('光照') || lowerMessage.contains('阳光')) {
      return '关于植物光照需求：\n\n**光照类型：**\n• 全日照：每天6+小时直射阳光\n• 半日照：每天3-6小时直射阳光\n• 散射光：明亮但无直射阳光\n• 低光照：较暗环境也能生存\n\n**常见问题：**\n• 光照过强：叶片晒伤、边缘焦黄\n• 光照不足：徒长、叶色变淡\n\n**解决方案：**\n• 观察植物状态调整位置\n• 使用遮阳网或补光灯\n• 循序渐进改变光照环境\n\n您的植物现在放在什么位置呢？';
    } else if (lowerMessage.contains('病虫害') || lowerMessage.contains('虫子') || lowerMessage.contains('病害')) {
      return '植物病虫害防治指南：\n\n**常见害虫：**\n• 蚜虫：用肥皂水喷洒\n• 红蜘蛛：增加湿度，用杀螨剂\n• 介壳虫：酒精擦拭或系统杀虫剂\n• 白粉虱：黄色粘虫板诱捕\n\n**常见病害：**\n• 根腐病：改善排水，修剪腐根\n• 叶斑病：移除病叶，改善通风\n• 白粉病：增加通风，减少湿度\n\n**预防措施：**\n• 定期检查植物\n• 保持良好通风\n• 避免叶面积水\n• 隔离新植物\n\n请拍照或详细描述症状，我可以帮您具体诊断！';
    } else if (lowerMessage.contains('多肉') || lowerMessage.contains('仙人掌')) {
      return '多肉植物养护要点：\n\n**浇水：**\n• 干透浇透，宁干勿湿\n• 春秋生长期适当增加\n• 夏冬休眠期控制浇水\n\n**光照：**\n• 喜充足散射光\n• 避免强烈直射阳光\n• 缺光易徒长变形\n\n**土壤：**\n• 排水良好的颗粒土\n• 可添加珍珠岩、蛭石\n\n**温度：**\n• 适宜温度15-25℃\n• 冬季不低于5℃\n\n**常见问题：**\n• 徒长：增加光照\n• 黑腐：减少浇水，改善通风\n• 掉叶：检查根系健康\n\n您的多肉遇到什么问题了吗？';
    } else {
      return '感谢您的咨询！作为植物养护专家，我很乐意为您解答问题。\n\n我可以帮助您解决以下问题：\n• 🌱 植物浇水和施肥\n• 🌞 光照和位置选择\n• 🍃 叶子发黄、掉落等症状\n• 🐛 病虫害识别和防治\n• 🌵 多肉植物特殊养护\n• 🏡 室内植物选择和搭配\n\n请详细描述您的植物情况，比如：\n- 植物种类\n- 当前症状\n- 养护环境\n- 最近的养护操作\n\n这样我可以给您更准确的建议！';
    }
  }

  void addMessage(ChatMessage message) {
    _chatHistory.add(message);
  }

  void updateMessage(String id, ChatMessage newMessage) {
    final index = _chatHistory.indexWhere((msg) => msg.id == id);
    if (index != -1) {
      _chatHistory[index] = newMessage;
    }
  }

  void removeMessage(String id) {
    _chatHistory.removeWhere((msg) => msg.id == id);
  }
}
