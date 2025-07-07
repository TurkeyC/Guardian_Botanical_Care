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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/plant_provider.dart';
import '../providers/settings_provider.dart';
import '../models/plant.dart';
import '../themes/app_themes.dart';
import '../widgets/apple_style_widgets.dart';
import '../widgets/apple_animations.dart';
import 'plant_detail_screen.dart';
import 'photo_identify_screen.dart';
import 'dart:io';

class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantProvider>().loadPlants();
    });
  }

  void _navigateToPhotoIdentify() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PhotoIdentifyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDynamicTheme = settingsProvider.currentTheme == AppThemeType.dynamic;

    return Scaffold(
      appBar: isDynamicTheme
          ? const GlassAppBar(title: '我的植物')
          : AppBar(
              title: const Text('我的植物'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
      body: isDynamicTheme
          ? ParticleBackground(
              child: _buildDynamicBody(),
            )
          : _buildMinimalBody(),
      floatingActionButton: isDynamicTheme
          ? AppleFAB(
              icon: Icons.add_a_photo_rounded,
              gradientColors: AppThemes.appleGreenGradient,
              onPressed: _navigateToPhotoIdentify,
            )
          : FloatingActionButton(
              onPressed: _navigateToPhotoIdentify,
              child: const Icon(Icons.add_a_photo),
            ),
    );
  }

  Widget _buildDynamicBody() {
    return Consumer<PlantProvider>(
      builder: (context, plantProvider, child) {
        if (plantProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (plantProvider.error != null) {
          return _buildDynamicErrorState(plantProvider);
        }

        if (plantProvider.plants.isEmpty) {
          return _buildDynamicEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => plantProvider.loadPlants(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plantProvider.plants.length,
            itemBuilder: (context, index) {
              final plant = plantProvider.plants[index];
              return AnimatedContainer2D(
                animationType: AnimationType.slideUp,
                duration: Duration(milliseconds: 600 + (index * 100)),
                child: DynamicPlantCard(
                  plant: plant,
                  onTap: () => _navigateToPlantDetail(plant),
                  onDelete: () => _showDeleteDialog(plant),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMinimalBody() {
    return Consumer<PlantProvider>(
      builder: (context, plantProvider, child) {
        if (plantProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (plantProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  plantProvider.error!,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => plantProvider.loadPlants(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (plantProvider.plants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '还没有识别过植物\n去拍照识别添加你的第一株植物吧！',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => plantProvider.loadPlants(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plantProvider.plants.length,
            itemBuilder: (context, index) {
              final plant = plantProvider.plants[index];
              return PlantCard(
                plant: plant,
                onTap: () => _navigateToPlantDetail(plant),
                onDelete: () => _showDeleteDialog(plant),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDynamicErrorState(PlantProvider plantProvider) {
    return Center(
      child: GlassContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFFF3B30),
            ),
            const SizedBox(height: 16),
            Text(
              plantProvider.error!,
              style: const TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            DynamicButton(
              text: '重试',
              onPressed: () => plantProvider.loadPlants(),
              gradientColors: AppThemes.appleOrangeGradient,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicEmptyState() {
    return Center(
      child: AnimatedContainer2D(
        animationType: AnimationType.combined,
        child: GlassContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppThemes.appleGreenGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '开始您的植物之旅',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '拍照识别您的第一株植物\n开启智能养护体验',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPlantDetail(Plant plant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantDetailScreen(plant: plant),
      ),
    );
  }

  void _showDeleteDialog(Plant plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除植物'),
        content: Text('确定要删除 "${plant.name}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PlantProvider>().deletePlant(plant.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 植物图片
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: plant.imagePath.startsWith('http')
                      ? Image.network(
                          plant.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : Image.file(
                          File(plant.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // 植物信息
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
                    if (plant.scientificName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        plant.scientificName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildHealthStatusChip(plant.healthStatus),
                        const SizedBox(width: 8),
                        Text(
                          '识别于 ${DateFormat('MM/dd').format(plant.identificationDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 删除按钮
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
              ),
            ],
          ),
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
        size: 30,
      ),
    );
  }

  Widget _buildHealthStatusChip(String healthStatus) {
    Color color;
    switch (healthStatus.toLowerCase()) {
      case '健康':
        color = Colors.green;
        break;
      case '一般':
        color = Colors.orange;
        break;
      case '不健康':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        healthStatus,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 灵动风格的植物卡片 - 苹果2.5D效果
class DynamicPlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DynamicPlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // 植物图片 - 圆角渐变边框
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: AppThemes.appleGreenGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppThemes.appleGreenGradient.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: plant.imagePath.startsWith('http')
                  ? Image.network(
                      plant.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDynamicPlaceholderImage(),
                    )
                  : Image.file(
                      File(plant.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDynamicPlaceholderImage(),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // 植物信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                if (plant.scientificName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    plant.scientificName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDynamicHealthChip(plant.healthStatus),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '识别于 ${DateFormat('MM/dd').format(plant.identificationDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFAEAEB2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 删除按钮 - 灵动样式
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30).withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFFF3B30),
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.eco_rounded,
        color: Color(0xFF8E8E93),
        size: 32,
      ),
    );
  }

  Widget _buildDynamicHealthChip(String healthStatus) {
    List<Color> gradientColors;
    switch (healthStatus.toLowerCase()) {
      case '健康':
        gradientColors = AppThemes.appleGreenGradient;
        break;
      case '一般':
        gradientColors = AppThemes.appleOrangeGradient;
        break;
      case '不健康':
        gradientColors = [const Color(0xFFFF3B30), const Color(0xFFFF6B35)];
        break;
      default:
        gradientColors = [const Color(0xFF8E8E93), const Color(0xFFAEAEB2)];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        healthStatus,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
