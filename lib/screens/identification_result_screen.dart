import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';

class IdentificationResultScreen extends StatelessWidget {
  final PlantIdentificationResult result;
  final File imageFile;

  const IdentificationResultScreen({
    super.key,
    required this.result,
    required this.imageFile,
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
              child: Image.file(
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

    final plant = Plant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: result.species,
      scientificName: result.scientificName,
      imagePath: imageFile.path,
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
    final healthyKeywords = ['健康', '良好', '正常'];
    final unhealthyKeywords = ['病', '虫', '枯', '黄', '不健康'];

    if (unhealthyKeywords.any((keyword) => healthAnalysis.contains(keyword))) {
      return '不健康';
    } else if (healthyKeywords.any((keyword) => healthAnalysis.contains(keyword))) {
      return '健康';
    } else {
      return '一般';
    }
  }

  /// 解析健康分析内容
  String _parseHealthAnalysis(String content) {
    try {
      // 尝试解析JSON格式的响应
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0)!);
        if (jsonData['health_analysis'] != null) {
          return jsonData['health_analysis'];
        }
      }
    } catch (e) {
      // JSON解析失败，返回原始内容
    }

    // 如果不是JSON格式或解析失败，返回原始内容
    return content;
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
