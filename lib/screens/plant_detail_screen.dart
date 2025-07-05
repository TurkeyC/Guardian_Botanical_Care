import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plant.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 植物图片
            Container(
              width: double.infinity,
              height: 250,
              child: plant.imagePath.startsWith('http')
                  ? Image.network(
                      plant.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    )
                  : Image.asset(
                      plant.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 基本信息
                  _buildInfoSection(
                    '基本信息',
                    [
                      _buildInfoRow('植物名称', plant.name),
                      if (plant.scientificName.isNotEmpty)
                        _buildInfoRow('学名', plant.scientificName),
                      _buildInfoRow('识别时间',
                          DateFormat('yyyy年MM月dd日 HH:mm').format(plant.identificationDate)),
                      _buildInfoRow('识别置信度', '${(plant.confidence * 100).toStringAsFixed(1)}%'),
                      _buildInfoRow('健康状态', plant.healthStatus),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 养护建议 - 使用解析后的格式
                  if (plant.careInstructions.isNotEmpty)
                    _buildCareRecommendationsSection(),

                  const SizedBox(height: 24),

                  // 具体养护信息 - 修复JSON显示问题
                  _buildInfoSection(
                    '养护要点',
                    [
                      if (plant.wateringFrequency.isNotEmpty)
                        _buildInfoRow('浇水频率', _parseSimpleText(plant.wateringFrequency)),
                      if (plant.lightRequirement.isNotEmpty)
                        _buildInfoRow('光照需求', _parseSimpleText(plant.lightRequirement)),
                      if (plant.fertilizingSchedule.isNotEmpty)
                        _buildInfoRow('施肥周期', _parseSimpleText(plant.fertilizingSchedule)),
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

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.eco,
          color: Colors.grey,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
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

  Widget _buildTextContent(String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }

  /// 构建养护建议section，支持JSON解析
  Widget _buildCareRecommendationsSection() {
    final recommendations = _parseCareRecommendations(plant.careInstructions);

    return _buildInfoSection(
      '养护建议',
      [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recommendations.entries
                  .map((entry) => _buildCareItem(entry.key, entry.value.toString()))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// 解析养护建议内容
  Map<String, dynamic> _parseCareRecommendations(String content) {
    try {
      // 首先尝试直接解析JSON字符串
      Map<String, dynamic> jsonData;

      try {
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

  /// 简单文本解析，支持解析带有换行的文本和JSON格式
  String _parseSimpleText(String content) {
    try {
      // 尝试解析JSON，提取具体的值
      final jsonData = jsonDecode(content);
      if (jsonData is Map<String, dynamic>) {
        // 如果是JSON对象，尝试提取有用的信息
        if (jsonData.containsKey('watering')) {
          return jsonData['watering'].toString();
        } else if (jsonData.containsKey('lighting')) {
          return jsonData['lighting'].toString();
        } else if (jsonData.containsKey('fertilization')) {
          return jsonData['fertilization'].toString();
        } else {
          // 如果找不到特定字段，返回第一个值
          return jsonData.values.first.toString();
        }
      }
    } catch (e) {
      // JSON解析失败，按照普通文本处理
    }

    // 普通文本处理：替换换行符为逗号并去除多余空格
    return content.replaceAll('\n', ', ').replaceAll(RegExp(r',\s*'), ', ').trim();
  }
}
