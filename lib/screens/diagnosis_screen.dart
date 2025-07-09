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
import 'ai_diagnosis_screen.dart'; // 导入AI诊断页面
import 'expert_consultation_screen.dart'; // 导入专家咨询页面

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  bool _devModeEnabled = false; // 开发者模式开关

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDynamic = settings.currentTheme == AppThemeType.dynamic;

        if (isDynamic) {
          return _buildDynamicScreen(context);
        } else {
          return _buildMinimalScreen(context);
        }
      },
    );
  }

  // 灵动主题版本 - 丰富动效
  Widget _buildDynamicScreen(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: '专业诊断',
      ),
      body: ParticleBackground(
        particleCount: 30,
        particleColor: Colors.blue.withValues(alpha: 0.3),
        particleSize: 1.5,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 主图标 - 带呼吸动画
                AnimatedContainer2D(
                  animationType: AnimationType.combined,
                  duration: const Duration(milliseconds: 800),
                  child: _DynamicIcon(),
                ),
                const SizedBox(height: 32),

                // 标题 - 渐变文字
                AnimatedContainer2D(
                  animationType: AnimationType.slideUp,
                  duration: const Duration(milliseconds: 600),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: AppThemes.appleBlueGradient,
                    ).createShader(bounds),
                    child: const Text(
                      '专业诊断服务',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 描述文字 - 毛玻璃容器
                AnimatedContainer2D(
                  animationType: AnimationType.fade,
                  duration: const Duration(milliseconds: 800),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '这里将提供更专业的植物健康诊断服务\n包括专家咨询、社区问答等功能',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // 功能卡片 - 使用浮动卡片和错位动画
                _buildDynamicFeatureCard(
                  icon: Icons.group,
                  title: '社区问答',
                  description: '与其他植物爱好者交流经验',
                  gradientColors: AppThemes.appleGreenGradient,
                  delay: 200,
                  onTap: () => _showComingSoonDialog(context, '社区问答'),
                ),
                const SizedBox(height: 16),
                _buildDynamicFeatureCard(
                  icon: Icons.psychology,
                  title: 'AI深度诊断',
                  description: '更精准的植物健康分析',
                  gradientColors: AppThemes.applePurpleGradient,
                  delay: 400,
                  isPro: true,
                  onTap: () => _devModeEnabled
                      ? _navigateToAiDiagnosis(context)
                      : _showOnlyForPro(context, 'AI深度诊断'),
                ),
                const SizedBox(height: 16),
                _buildDynamicFeatureCard(
                  icon: Icons.person_outline,
                  title: '专家咨询',
                  description: '预约专业园艺师一对一指导',
                  gradientColors: AppThemes.appleOrangeGradient,
                  delay: 600,
                  isPro: true,
                  onTap: () => _devModeEnabled
                      ? _navigateToExpertConsultation(context)
                      : _showOnlyForPro(context, '专家咨询'),
                ),
                const SizedBox(height: 24),

                // 开发者模式开关
                AnimatedContainer2D(
                  animationType: AnimationType.fade,
                  duration: const Duration(milliseconds: 400),
                  child: _buildDevModeSwitch(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 简约主题版本 - 保持原样
  Widget _buildMinimalScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('专业诊断'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 120,
                color: Colors.blue[300],
              ),
              const SizedBox(height: 32),
              const Text(
                '专业诊断服务',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '这里将提供更专业的植物健康诊断服务\n包括专家咨询、社区问答等功能',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // 功能卡片 - 保持原样
              _buildFeatureCard(
                icon: Icons.group,
                title: '社区问答',
                description: '与其他植物爱好者交流经验',
                color: Colors.green,
                onTap: () => _showComingSoonDialog(context, '社区问答'),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.psychology,
                title: 'AI深度诊断',
                description: '更精准的植物健康分析',
                color: Colors.purple,
                isPro: true,
                onTap: () => _devModeEnabled
                    ? _navigateToAiDiagnosis(context)
                    : _showOnlyForPro(context, 'AI深度诊断'),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.person_outline,
                title: '专家咨询',
                description: '预约专业园艺师一对一指导',
                color: Colors.orange,
                isPro: true,
                onTap: () => _devModeEnabled
                    ? _navigateToExpertConsultation(context)
                    : _showOnlyForPro(context, '专家咨询'),
              ),
              const SizedBox(height: 24),

              // 开发者模式开关
              _buildDevModeSwitch(),
            ],
          ),
        ),
      ),
    );
  }

  // 灵动主题的功能卡片
  Widget _buildDynamicFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required int delay,
    bool isPro = false,
  }) {
    return AnimatedContainer2D(
      animationType: AnimationType.slideLeft,
      duration: Duration(milliseconds: 600 + delay),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: gradientColors.first.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: gradientColors.first,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (isPro) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1A1A1A), Color(0xFFD4AF37)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Pro',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 原有的简约主题功能卡片
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool isPro = false,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPro) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A1A1A), Color(0xFFD4AF37)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('该功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showOnlyForPro(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('该功能属于Pro会员专属功能！'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '开通Pro会员，立即享受专业植物诊断服务',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
          ElevatedButton(
            onPressed: () {
              // 先关闭对话框
              Navigator.pop(context);
              // 跳转到会员页面
              Navigator.pushNamed(context, '/membership');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            child: const Text('开通Pro会员'),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  // 开发者模式开关组件
  Widget _buildDevModeSwitch() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _devModeEnabled = !_devModeEnabled;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '开发者模式',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Switch(
              value: _devModeEnabled,
              onChanged: (value) {
                setState(() {
                  _devModeEnabled = value;
                });
              },
              activeColor: const Color(0xFFD4AF37),
              inactiveTrackColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAiDiagnosis(BuildContext context) {
    // 显示加载中提示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('AI深度诊断'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('尊敬的VIP用户, 欢迎使用AI深度诊断功能, 正在加载中...'),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

    // 延迟一会后关闭对话框并跳转到AI诊断页面
    Future.delayed(const Duration(seconds: 2), () {
      // 关闭加载对话框
      Navigator.pop(context);
      // 导航到AI诊断页面
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AiDiagnosisScreen()),
      );
    });
  }

  void _navigateToExpertConsultation(BuildContext context) {
    // 显示加载中提示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('专家咨询'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('尊敬的VIP用户, 欢迎使用专家咨询功能, 正在加载中...'),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

    // 延迟一会后关闭对话框并跳转到专家咨询页面
    Future.delayed(const Duration(seconds: 2), () {
      // 关闭加载对话框
      Navigator.pop(context);
      // 导航到专家咨询页面
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExpertConsultationScreen()),
      );
    });
  }
}

// 灵动主题的动态图标组件
class _DynamicIcon extends StatefulWidget {
  @override
  State<_DynamicIcon> createState() => _DynamicIconState();
}

class _DynamicIconState extends State<_DynamicIcon>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _glowController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 呼吸动画控制器
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // 发光动画控制器
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathingAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4A90E2),  // 更柔和的蓝色
                  Color(0xFF7B68EE),  // 淡紫色
                  Color(0xFF50C878),  // 薄荷绿
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withValues(alpha: _glowAnimation.value),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFF7B68EE).withValues(alpha: _glowAnimation.value * 0.6),
                  blurRadius: 35,
                  offset: const Offset(0, 15),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
