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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../themes/app_themes.dart';
import '../widgets/apple_style_widgets.dart';
import '../widgets/apple_animations.dart';
import 'dart:async';

class AiDiagnosisScreen extends StatefulWidget {
  const AiDiagnosisScreen({super.key});

  @override
  State<AiDiagnosisScreen> createState() => _AiDiagnosisScreenState();
}

class _AiDiagnosisScreenState extends State<AiDiagnosisScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isAnalyzing = false;
  String _statusMessage = '正在初始化AI深度诊断模型...';
  double _progress = 0.0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _loadingMessages = [
    '加载高精度植物识别模型...',
    '初始化AI深度诊断引擎...',
    '连接云端数据库...',
    '准备诊断参数...',
    '校准图像分析模块...',
  ];

  final List<Map<String, dynamic>> _diagnosisResults = [
    {
      'title': '叶片黄化',
      'confidence': 0.92,
      'description': '植物叶片出现黄化现象，可能是由于缺乏氮元素或光照不足导致。',
      'solutions': [
        '增加氮肥施用量',
        '确保植物每天能接收到充足的光照',
        '控制浇水频率，避免过度浇水'
      ]
    },
    {
      'title': '叶缘褐变',
      'confidence': 0.78,
      'description': '叶片边缘出现褐色，这通常是由于水分管理不当或空气湿度过低引起的。',
      'solutions': [
        '保持土壤湿润但不过湿',
        '增加周围空气湿度',
        '避免将植物放置在暖气或空调出风口附近'
      ]
    },
    {
      'title': '生长缓慢',
      'confidence': 0.65,
      'description': '植物生长速度明显减慢，可能是由于养分不足或生长环境不适宜。',
      'solutions': [
        '适量使用均衡的植物营养液',
        '确保温度适宜',
        '考虑更换更大的花盆以促进根系发展'
      ]
    }
  ];

  @override
  void initState() {
    super.initState();

    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // 模拟加载过程
    _simulateLoading();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // 模拟AI模型加载过程
  void _simulateLoading() {
    int messageIndex = 0;
    const loadingDuration = Duration(milliseconds: 5000); // 总加载时间
    const updateInterval = Duration(milliseconds: 100);   // 进度条更新间隔

    // 计算每次更新的进度增量
    final progressIncrement = updateInterval.inMilliseconds / loadingDuration.inMilliseconds;
    final messageInterval = loadingDuration.inMilliseconds / _loadingMessages.length;

    Timer.periodic(updateInterval, (timer) {
      if (_progress >= 1.0) {
        timer.cancel();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _progress += progressIncrement;

        // 定期更换加载消息
        if (timer.tick % (messageInterval ~/ updateInterval.inMilliseconds) == 0 &&
            messageIndex < _loadingMessages.length - 1) {
          messageIndex++;
          _statusMessage = _loadingMessages[messageIndex];
        }
      });
    });
  }

  // 模拟图片分析过程
  void _simulateAnalysis() {
    setState(() {
      _isAnalyzing = true;
      _progress = 0.0;
      _statusMessage = '正在分析图像...';
    });

    const analysisDuration = Duration(milliseconds: 3000);
    const updateInterval = Duration(milliseconds: 50);
    final progressIncrement = updateInterval.inMilliseconds / analysisDuration.inMilliseconds;

    Timer.periodic(updateInterval, (timer) {
      if (_progress >= 1.0) {
        timer.cancel();
        setState(() {
          _isAnalyzing = false;
        });
        return;
      }

      setState(() {
        _progress += progressIncrement;

        if (_progress > 0.3 && _progress < 0.4) {
          _statusMessage = '检测植物类型...';
        } else if (_progress > 0.6 && _progress < 0.7) {
          _statusMessage = '分析健康状况...';
        } else if (_progress > 0.9) {
          _statusMessage = '生成诊断报告...';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDynamic = settings.currentTheme == AppThemeType.dynamic;

        return isDynamic
            ? _buildDynamicScreen(context)
            : _buildMinimalScreen(context);
      },
    );
  }

  // 灵动主题版本
  Widget _buildDynamicScreen(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'AI深度诊断',
      ),
      body: ParticleBackground(
        particleCount: 40,
        particleColor: Colors.purple.withValues(alpha: 0.2),
        particleSize: 2.0,
        child: _isLoading
            ? _buildLoadingView(true)
            : _buildMainContent(true),
      ),
    );
  }

  // 简约主题版本
  Widget _buildMinimalScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI深度诊断'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? _buildLoadingView(false)
          : _buildMainContent(false),
    );
  }

  // 加载视图
  Widget _buildLoadingView(bool isDynamic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isDynamic) ...[
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF9C27B0),
                            Color(0xFF7B1FA2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              const CircularProgressIndicator(
                color: Colors.purple,
                strokeWidth: 5,
              ),
            ],

            const SizedBox(height: 32),

            Text(
              'AI深度诊断',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDynamic
                    ? Colors.white
                    : Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDynamic
                    ? Colors.white70
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),

            const SizedBox(height: 32),

            // 进度条
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: isDynamic
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 10,
                            width: MediaQuery.of(context).size.width * 0.8 * _progress,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[300],
                      color: Colors.purple,
                    ),
            ),

            const SizedBox(height: 16),

            Text(
              '${(_progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDynamic ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 主内容区域
  Widget _buildMainContent(bool isDynamic) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 上传图片区域
              _buildImageUploader(isDynamic),

              const SizedBox(height: 32),

              // 诊断结果部分
              Text(
                '诊断结果',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDynamic ? Colors.white : null,
                ),
              ),

              const SizedBox(height: 16),

              ..._diagnosisResults.map((result) => _buildResultCard(result, isDynamic)).toList(),

              const SizedBox(height: 24),

              // 底部操作按钮
              _buildActionButtons(isDynamic),
            ],
          ),
        ),

        // 分析中遮罩
        if (_isAnalyzing)
          _buildAnalyzingOverlay(isDynamic),
      ],
    );
  }

  // 图片上传区域
  Widget _buildImageUploader(bool isDynamic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDynamic
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDynamic
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: isDynamic
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDynamic
                    ? Colors.purple.withValues(alpha: 0.4)
                    : Colors.grey[400]!,
                width: isDynamic ? 2 : 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 60,
                    color: isDynamic
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.grey[500],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '点击上传植物图片',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDynamic
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '支持JPG、PNG格式，最大10MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDynamic
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // 模拟分析过程
              _simulateAnalysis();
            },
            icon: const Icon(Icons.search),
            label: const Text('开始分析'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDynamic ? Colors.purple : null,
              foregroundColor: isDynamic ? Colors.white : null,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
        ],
      ),
    );
  }

  // 诊断结果卡片
  Widget _buildResultCard(Map<String, dynamic> result, bool isDynamic) {
    final confidencePercentage = (result['confidence'] * 100).toInt();
    final confidenceColor = confidencePercentage > 85
        ? Colors.green
        : (confidencePercentage > 70 ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDynamic
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDynamic
              ? Colors.purple.withValues(alpha: 0.3)
              : Colors.grey[300]!,
        ),
        boxShadow: isDynamic
            ? [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDynamic
                  ? Colors.purple.withValues(alpha: 0.2)
                  : Colors.purple[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    result['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDynamic ? Colors.white : Colors.purple[700],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: confidenceColor.withValues(alpha: isDynamic ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: confidenceColor.withValues(alpha: isDynamic ? 0.6 : 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 14,
                        color: confidenceColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '置信度 $confidencePercentage%',
                        style: TextStyle(
                          fontSize: 12,
                          color: confidenceColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 内容区域
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 描述
                Text(
                  result['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDynamic ? Colors.white70 : null,
                  ),
                ),

                const SizedBox(height: 16),

                // 解决方案
                Text(
                  '解决方案',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDynamic ? Colors.white70 : null,
                  ),
                ),

                const SizedBox(height: 8),

                ...List.generate(
                  result['solutions'].length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: isDynamic ? Colors.green[300] : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result['solutions'][index],
                            style: TextStyle(
                              color: isDynamic ? Colors.white70 : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 底部操作按钮
  Widget _buildActionButtons(bool isDynamic) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_alt),
            label: const Text('保存报告'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDynamic ? Colors.white : null,
              side: BorderSide(
                color: isDynamic ? Colors.white.withValues(alpha: 0.5) : Colors.grey[400]!,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('分享'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDynamic ? Colors.purple : null,
              foregroundColor: isDynamic ? Colors.white : null,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // 分析中遮罩
  Widget _buildAnalyzingOverlay(bool isDynamic) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDynamic) ...[
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF9C27B0),
                            Color(0xFF7B1FA2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C27B0).withValues(alpha: 0.7),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.search,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              const CircularProgressIndicator(
                color: Colors.purple,
              ),
            ],

            const SizedBox(height: 24),

            Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 6,
                      width: MediaQuery.of(context).size.width * 0.7 * _progress,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${(_progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
