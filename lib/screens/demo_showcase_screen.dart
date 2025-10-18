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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../themes/app_themes.dart';
import '../widgets/apple_style_widgets.dart';
import '../models/plant.dart';
import 'identification_result_screen.dart';

class DemoShowcaseScreen extends StatefulWidget {
  const DemoShowcaseScreen({super.key});

  @override
  State<DemoShowcaseScreen> createState() => _DemoShowcaseScreenState();
}

class _DemoShowcaseScreenState extends State<DemoShowcaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;

  // Demo数据 - 基于解读.md内容
  final Plant _demoPlant = Plant(
    id: 'demo_monstera',
    name: '龙血树属 百合竹',
    scientificName: 'Dracaena reflexa',
    imagePath: 'assets/demo/monstera.jpg',
    identificationDate: DateTime(2025, 7, 9, 7, 21),
    healthStatus: '一般',
    confidence: 0.93,
    careInstructions: '''健康状态评估-叶片状况: 叶片颜色为深绿色，整体较为浓密，但部分叶片边缘略显发黄或干枯。叶片细长，呈线状披针形，符合该植物的自然生长特征。部分叶片边缘有轻微卷曲和干枯现象，但整体叶片并未大面积枯萎。

健康状态评估-生长状态: 该植物整体形态较为正常，无明显病虫害迹象，枝条分布均匀，植株高度适中，分枝较多，显示出良好的分枝能力。树干挺拔，支撑力较强，表明植株生长稳定。但是枝叶末端干枯，显示出其健康状况并非最佳。''',
    wateringFrequency: '每周浇水一次，具体频率根据环境湿度调整，确保土壤表面干燥后再浇水',
    lightRequirement: '该植物喜散射光，适合放置在明亮但无直射阳光的位置，避免强光直射',
    fertilizingSchedule: '生长季节（春季至秋季）每月施用一次稀释的液体肥料，冬季减少施肥频率或停止施肥',
  );

  final List<String> _stepTitles = [
    '选择植物图片',
    'AI智能识别中',
    '识别结果展示',
    '完整功能演示',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _slideController.reset();
      _slideController.forward();
    }
  }

  void _simulateIdentification() {
    setState(() {
      _currentStep = 1;
    });

    // 模拟识别过程
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _currentStep = 2;
      });
      _slideController.reset();
      _slideController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDynamicTheme = settingsProvider.currentTheme == AppThemeType.dynamic;

    return Scaffold(
      appBar: isDynamicTheme
          ? const GlassAppBar(title: 'GBC 功能演示')
          : AppBar(
              title: const Text('GBC 功能演示'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildCurrentStep(context, isDynamicTheme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, bool isDynamicTheme) {
    switch (_currentStep) {
      case 0:
        return _buildImageSelectionStep(context, isDynamicTheme);
      case 1:
        return _buildProcessingStep(context, isDynamicTheme);
      case 2:
        return _buildResultStep(context, isDynamicTheme);
      case 3:
        return _buildFullFeaturesStep(context, isDynamicTheme);
      default:
        return _buildImageSelectionStep(context, isDynamicTheme);
    }
  }

  Widget _buildImageSelectionStep(BuildContext context, bool isDynamicTheme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildStepIndicator(),
          const SizedBox(height: 30),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  '选择或拍摄植物照片',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '我们将使用Demo图片进行演示',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Demo图片预览
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/demo/monstera.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    _simulateIdentification();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('开始识别'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingStep(BuildContext context, bool isDynamicTheme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildStepIndicator(),
          const SizedBox(height: 30),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 30),
                Text(
                  'AI正在识别中...',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  '正在分析植物特征\n评估健康状态\n生成养护建议',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep(BuildContext context, bool isDynamicTheme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildStepIndicator(),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 识别结果卡片
                  _buildResultCard(context, isDynamicTheme),
                  const SizedBox(height: 20),
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _navigateToDetailResult(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: const Text('查看详细结果'),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          ),
                          child: const Text('更多功能'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullFeaturesStep(BuildContext context, bool isDynamicTheme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildStepIndicator(),
          const SizedBox(height: 20),
          Text(
            'GBC 完整功能展示',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildFeatureCard(
                  context,
                  isDynamicTheme,
                  Icons.eco_rounded,
                  '我的植物',
                  '管理您的植物收藏',
                  Colors.green,
                ),
                _buildFeatureCard(
                  context,
                  isDynamicTheme,
                  Icons.medical_services_rounded,
                  'AI诊断',
                  '智能健康诊断',
                  Colors.blue,
                ),
                _buildFeatureCard(
                  context,
                  isDynamicTheme,
                  Icons.support_agent_rounded,
                  '专家咨询',
                  '专业园艺师指导',
                  Colors.orange,
                ),
                _buildFeatureCard(
                  context,
                  isDynamicTheme,
                  Icons.forum_rounded,
                  '社区问答',
                  '植友交流互助',
                  Colors.purple,
                ),
                _buildFeatureCard(
                  context,
                  isDynamicTheme,
                  Icons.notifications_rounded,
                  '养护提醒',
                  '智能养护提醒',
                  Colors.red,
                ),
                _buildFeatureCard(
                  context,
                  isDynamicTheme,
                  Icons.camera_alt_rounded,
                  '拍照识别',
                  '快速植物识别',
                  Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_stepTitles.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index <= _currentStep
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: index <= _currentStep
                          ? Colors.white
                          : Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _stepTitles[index],
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildResultCard(BuildContext context, bool isDynamicTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildResultContent(context),
      ),
    );
  }

  Widget _buildResultContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/demo/monstera.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _demoPlant.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _demoPlant.scientificName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '置信度: ${(_demoPlant.confidence * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildHealthStatus(context),
      ],
    );
  }

  Widget _buildHealthStatus(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (_demoPlant.healthStatus) {
      case '优秀':
        statusColor = Colors.green;
        statusIcon = Icons.eco;
        break;
      case '良好':
        statusColor = Colors.lightGreen;
        statusIcon = Icons.eco;
        break;
      case '一般':
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber;
        break;
      case '较差':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 6),
          Text(
            '健康状态: ${_demoPlant.healthStatus}',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    bool isDynamicTheme,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetailResult(BuildContext context) {
    // 创建一个模拟的PlantIdentificationResult对象
    final demoResult = PlantIdentificationResult(
      species: _demoPlant.name,
      scientificName: _demoPlant.scientificName,
      confidence: _demoPlant.confidence,
      healthAnalysis: _demoPlant.careInstructions,
      careRecommendations: '''
养护建议-光照需求: ${_demoPlant.lightRequirement}

养护建议-浇水指导: ${_demoPlant.wateringFrequency}

养护建议-施肥建议: ${_demoPlant.fertilizingSchedule}
      '''.trim(),
      imagePath: _demoPlant.imagePath,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdentificationResultScreen(
          result: demoResult,
          imageFile: File('assets/demo/monstera.jpg'),
        ),
      ),
    );
  }
}
