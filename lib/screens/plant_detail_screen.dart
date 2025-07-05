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

                  // 养护建议
                  if (plant.careInstructions.isNotEmpty)
                    _buildInfoSection(
                      '养护建议',
                      [
                        _buildTextContent(plant.careInstructions),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // 具体养护信息
                  _buildInfoSection(
                    '养护要点',
                    [
                      if (plant.wateringFrequency.isNotEmpty)
                        _buildInfoRow('浇水频率', plant.wateringFrequency),
                      if (plant.lightRequirement.isNotEmpty)
                        _buildInfoRow('光照需求', plant.lightRequirement),
                      if (plant.fertilizingSchedule.isNotEmpty)
                        _buildInfoRow('施肥周期', plant.fertilizingSchedule),
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
}
