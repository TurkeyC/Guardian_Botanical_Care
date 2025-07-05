import 'dart:io';
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
                        _buildInfoRow('学名', result.scientificName),
                        _buildInfoRow('识别置信度', '${(result.confidence * 100).toStringAsFixed(1)}%'),
                      ]),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 健康状况分析
                  _buildSection(
                    '🔍 健康状况分析',
                    [
                      _buildTextCard(result.healthAnalysis),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 养护建议
                  _buildSection(
                    '💡 养护建议',
                    [
                      _buildTextCard(result.careRecommendations),
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
                          label: const Text('重新识别'),
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
}
