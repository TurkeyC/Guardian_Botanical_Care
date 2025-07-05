import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/plant_provider.dart';
import '../models/plant.dart';

class CareReminderScreen extends StatefulWidget {
  const CareReminderScreen({super.key});

  @override
  State<CareReminderScreen> createState() => _CareReminderScreenState();
}

class _CareReminderScreenState extends State<CareReminderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('养护提醒'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<PlantProvider>(
        builder: (context, plantProvider, child) {
          if (plantProvider.plants.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '暂无植物需要养护提醒\n先去添加一些植物吧！',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plantProvider.plants.length,
            itemBuilder: (context, index) {
              final plant = plantProvider.plants[index];
              return CareReminderCard(plant: plant);
            },
          );
        },
      ),
    );
  }
}

class CareReminderCard extends StatelessWidget {
  final Plant plant;

  const CareReminderCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 50,
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '添加于 ${DateFormat('MM/dd').format(plant.identificationDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 养护提醒项
            _buildReminderItem(
              icon: Icons.water_drop,
              title: '浇水提醒',
              description: plant.wateringFrequency.isNotEmpty
                  ? plant.wateringFrequency
                  : '每3-5天浇水一次',
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildReminderItem(
              icon: Icons.wb_sunny,
              title: '光照检查',
              description: plant.lightRequirement.isNotEmpty
                  ? plant.lightRequirement
                  : '确保充足散射光',
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildReminderItem(
              icon: Icons.eco,
              title: '施肥提醒',
              description: plant.fertilizingSchedule.isNotEmpty
                  ? plant.fertilizingSchedule
                  : '春夏季每月施肥一次',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.eco,
        color: Colors.grey,
        size: 25,
      ),
    );
  }

  Widget _buildReminderItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
