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

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';

class IdentificationResultScreen extends StatelessWidget {
  final PlantIdentificationResult result;
  final File imageFile;
  final bool isDemoMode; // 添加Demo模式标识

  const IdentificationResultScreen({
    super.key,
    required this.result,
    required this.imageFile,
    this.isDemoMode = false, // 默认为false
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('识别结果'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 原始图像
            Container(
              width: double.infinity,
              height: 250,
              child: isDemoMode
                  ? Image.asset(
                      'assets/demo/monstera.jpg',
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 识别结果
                  _buildSection(
                    '🌿 植物识别结果',
                    [
                      _buildInfoCard([
                        _buildInfoRow('植物名称', result.species),
                        _buildInfoRow('学名', result.scientificName.isNotEmpty ? result.scientificName : '暂无学名信息'),
                        _buildInfoRow('识别置信度', '${(result.confidence * 100).toStringAsFixed(1)}%'),
                      ]),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 健康状况分析
                  _buildSection(
                    '🔍 健康状况分析',
                    [
                      _buildAnalysisCard(_parseHealthAnalysis(result.healthAnalysis)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 养护建议
                  _buildSection(
                    '💡 养护建议',
                    [
                      _buildCareRecommendationsCard(_parseCareRecommendations(result.careRecommendations)),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _addToMyPlants(context),
                          icon: const Icon(Icons.add),
                          label: const Text('添加到我的植物'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _retryIdentification(context),
                          icon: const Icon(Icons.refresh),
                          label: const Text('重新上传'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextCard(String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _addToMyPlants(BuildContext context) {
    // 从养护建议中提取结构化信息
    final careAdvice = result.careRecommendations;
    final wateringFrequency = _extractWateringInfo(careAdvice);
    final lightRequirement = _extractLightInfo(careAdvice);
    final fertilizingSchedule = _extractFertilizingInfo(careAdvice);

    // 从健康分析中提取健康状态
    final healthStatus = _extractHealthStatus(result.healthAnalysis);

    // 在Demo模式下，使用特殊的imagePath来标识这是assets图片
    final imagePath = isDemoMode ? 'DEMO_ASSETS_IMAGE' : imageFile.path;

    final plant = Plant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: result.species,
      scientificName: result.scientificName,
      imagePath: imagePath,
      identificationDate: DateTime.now(),
      healthStatus: healthStatus,
      confidence: result.confidence,
      careInstructions: result.careRecommendations,
      wateringFrequency: wateringFrequency,
      lightRequirement: lightRequirement,
      fertilizingSchedule: fertilizingSchedule,
    );

    context.read<PlantProvider>().addPlant(plant).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已添加到我的植物'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('添加失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _retryIdentification(BuildContext context) {
    Navigator.of(context).pop();
  }

  String _extractWateringInfo(String careAdvice) {
    // 简单的文本提取逻辑，可以根据需要优化
    final wateringKeywords = ['浇水', '水分', '湿润'];
    final lines = careAdvice.split('\n');

    for (final line in lines) {
      if (wateringKeywords.any((keyword) => line.contains(keyword))) {
        return line.trim();
      }
    }
    return '根据土壤湿度调整';
  }

  String _extractLightInfo(String careAdvice) {
    final lightKeywords = ['光照', '阳光', '照明'];
    final lines = careAdvice.split('\n');

    for (final line in lines) {
      if (lightKeywords.any((keyword) => line.contains(keyword))) {
        return line.trim();
      }
    }
    return '适中光照';
  }

  String _extractFertilizingInfo(String careAdvice) {
    final fertilizingKeywords = ['施肥', '肥料', '营养'];
    final lines = careAdvice.split('\n');

    for (final line in lines) {
      if (fertilizingKeywords.any((keyword) => line.contains(keyword))) {
        return line.trim();
      }
    }
    return '春夏季每月一次';
  }

  String _extractHealthStatus(String healthAnalysis) {
    // 先解析JSON格式的健康分析内容
    String parsedContent = _parseHealthAnalysis(healthAnalysis);

    // 调试输出
    print('原始健康分析内容: $healthAnalysis');
    print('解析后的内容: $parsedContent');

    // 首先检查明确的不健康状态 - 使用更精确的词汇避免误判
    final unhealthyKeywords = ['不健康', '病害', '虫害', '枯萎', '病虫害', '患病', '萎蔫', '腐烂', '斑点', '虫蛀', '病变', '感染', '叶片发黄', '黄化病', '枯黄'];
    // 然后检查健康状态 - 使用更精确的匹配
    final healthyKeywords = ['健康良好', '生长旺盛', '状态良好', '鲜绿', '茁壮', '正常生长', '长势良好', '表明健康', '显示健康', '看起来健康', '健康状况', '良好的生长', '显示出良好'];
    // 最后检查一般状态
    final normalKeywords = ['一般', '普通', '尚可', '中等'];

    String result;

    // 优先检查明确的不健康关键词
    if (unhealthyKeywords.any((keyword) => parsedContent.contains(keyword))) {
      result = '不健康';
      print('匹配到不健康关键词');
    }
    // 检查健康关键词
    else if (healthyKeywords.any((keyword) => parsedContent.contains(keyword))) {
      result = '健康';
      print('匹配到健康关键词');
    }
    // 特殊处理：如果包含"健康"但不包含明确的不健康词汇
    else if (parsedContent.contains('健康') && !unhealthyKeywords.any((keyword) => parsedContent.contains(keyword))) {
      result = '健康';
      print('包含健康但无不健康关键词');
    }
    // 检查一般状态关键词
    else if (normalKeywords.any((keyword) => parsedContent.contains(keyword))) {
      result = '一般';
      print('匹配到一般关键词');
    }
    // 如果都没有匹配到，默认返回健康（积极判断）
    else {
      result = '健康';
      print('默认判断为健康');
    }

    print('最终健康状态判断结果: $result');
    return result;
  }

  /// 解析健康分析内容
  String _parseHealthAnalysis(String content) {
    try {
      // 首先检查是否是Map格式的字符串
      if (content.startsWith('{') && content.endsWith('}')) {
        // 尝试将Map格式字符串转换为JSON并解析
        String jsonString = content
            .replaceAllMapped(RegExp(r'(\w+):'), (match) => '"${match.group(1)}":')  // 给key加引号
            .replaceAllMapped(RegExp(r': ([^,}]+)'), (match) => ': "${match.group(1)}"');  // 给value加引号

        try {
          final jsonData = jsonDecode(jsonString);
          return _formatHealthAnalysisFromMap(jsonData);
        } catch (e) {
          // 如果JSON转换失败，手动解析Map格式
          return _parseMapFormatContent(content);
        }
      }

      // 尝试解析标准JSON格式的响应
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0)!);
        return _formatHealthAnalysisFromMap(jsonData);
      }
    } catch (e) {
      // JSON解析失败，返回原始内容
      print('JSON解析失败: $e');
    }

    // 如果不是JSON格式或解析失败，返回原始内容
    return content;
  }

  /// 格式化从Map解析出的健康分析内容
  String _formatHealthAnalysisFromMap(Map<String, dynamic> jsonData) {
    StringBuffer result = StringBuffer();

    // 如果有health_analysis字段，直接返回
    if (jsonData['health_analysis'] != null) {
      return jsonData['health_analysis'];
    }

    // 如果是叶片状况和生长状态的格式
    if (jsonData['leaf_condition'] != null || jsonData['growth_status'] != null) {
      if (jsonData['leaf_condition'] != null) {
        result.write('叶片状况：${jsonData['leaf_condition']}');
      }
      if (jsonData['growth_status'] != null) {
        if (result.isNotEmpty) result.write('\n\n');
        result.write('生长状态：${jsonData['growth_status']}');
      }
      return result.toString();
    }

    // 处理其他可能的JSON字段
    for (var entry in jsonData.entries) {
      if (result.isNotEmpty) result.write('\n\n');
      String key = _translateKey(entry.key);
      result.write('$key：${entry.value}');
    }

    return result.toString();
  }

  /// 手动解析Map格式的内容
  String _parseMapFormatContent(String content) {
    StringBuffer result = StringBuffer();

    // 移除开头和结尾的大括号
    String cleanContent = content.substring(1, content.length - 1);

    // 按逗号分割键值对
    List<String> pairs = [];
    int braceCount = 0;
    int start = 0;

    for (int i = 0; i < cleanContent.length; i++) {
      if (cleanContent[i] == '{') braceCount++;
      if (cleanContent[i] == '}') braceCount--;
      if (cleanContent[i] == ',' && braceCount == 0) {
        pairs.add(cleanContent.substring(start, i).trim());
        start = i + 1;
      }
    }
    pairs.add(cleanContent.substring(start).trim());

    // 解析每个键值对
    for (String pair in pairs) {
      int colonIndex = pair.indexOf(':');
      if (colonIndex > 0) {
        String key = pair.substring(0, colonIndex).trim();
        String value = pair.substring(colonIndex + 1).trim();

        String translatedKey = _translateKey(key);
        if (result.isNotEmpty) result.write('\n\n');
        result.write('$translatedKey：$value');
      }
    }

    return result.toString();
  }

  /// 翻译JSON字段名为中文
  String _translateKey(String key) {
    switch (key.toLowerCase()) {
      case 'leaf_condition':
        return '叶片状况';
      case 'growth_status':
        return '生长状态';
      case 'health_status':
        return '健康状态';
      case 'overall_health':
        return '整体健康';
      case 'disease_signs':
        return '病害征象';
      case 'pest_signs':
        return '虫害征象';
      case 'recommendations':
        return '建议';
      default:
        return key;
    }
  }

  /// 解析养护建议内容
  Map<String, dynamic> _parseCareRecommendations(String content) {
    try {
      // 首先尝试直接解析，因为从VLM API返回的可能已经是JSON字符串
      Map<String, dynamic> jsonData;

      try {
        // 尝试直接解析JSON字符串
        jsonData = jsonDecode(content);
      } catch (e) {
        // 如果直接解析失败，尝试从文本中提取JSON
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          jsonData = jsonDecode(jsonMatch.group(0)!);
        } else {
          // 如果都失败了，返回原始内容
          return {'general': content};
        }
      }

      // 如果解析成功，返回解析后的数据
      if (jsonData is Map<String, dynamic>) {
        return jsonData;
      } else {
        return {'general': content};
      }
    } catch (e) {
      // JSON解析失败，返回原始内容
      return {'general': content};
    }
  }

  /// 构建健康分析卡片
  Widget _buildAnalysisCard(String analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: Colors.green[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '健康状态评估',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              analysis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建养护建议卡片
  Widget _buildCareRecommendationsCard(Map<String, dynamic> recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.eco,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '养护指南',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.entries.map((entry) => _buildCareItem(entry.key, entry.value.toString())),
          ],
        ),
      ),
    );
  }

  /// 构建单个养护建议项
  Widget _buildCareItem(String category, String advice) {
    IconData icon;
    Color color;
    String title;

    switch (category.toLowerCase()) {
      case 'lighting':
      case 'light':
        icon = Icons.wb_sunny;
        color = Colors.orange;
        title = '光照需求';
        break;
      case 'watering':
      case 'water':
        icon = Icons.water_drop;
        color = Colors.blue;
        title = '浇水指导';
        break;
      case 'temperature':
      case 'temp':
        icon = Icons.thermostat;
        color = Colors.red;
        title = '温度要求';
        break;
      case 'humidity':
        icon = Icons.opacity;
        color = Colors.cyan;
        title = '湿度环境';
        break;
      case 'fertilization':
      case 'fertilizer':
        icon = Icons.grass;
        color = Colors.green;
        title = '施肥建议';
        break;
      case 'pruning':
        icon = Icons.content_cut;
        color = Colors.purple;
        title = '修剪护理';
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
        title = '养护建议';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
