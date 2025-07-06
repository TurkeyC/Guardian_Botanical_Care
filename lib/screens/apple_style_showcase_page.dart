import 'package:flutter/material.dart';
import '../widgets/apple_style_widgets.dart';
import '../widgets/apple_animations.dart';
import '../themes/app_themes.dart';

/// 苹果风格展示页面 - 展示所有高级组件效果
class AppleStyleShowcasePage extends StatefulWidget {
  const AppleStyleShowcasePage({super.key});

  @override
  State<AppleStyleShowcasePage> createState() => _AppleStyleShowcasePageState();
}

class _AppleStyleShowcasePageState extends State<AppleStyleShowcasePage>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 毛玻璃AppBar
      appBar: const GlassAppBar(
        title: '苹果灵动风格',
      ),

      // 粒子动画背景
      body: ParticleBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 渐变卡片展示区
            _buildGradientCardsSection(),

            const SizedBox(height: 24),

            // 毛玻璃容器展示区
            _buildGlassContainersSection(),

            const SizedBox(height: 24),

            // 动画按钮展示区
            _buildAnimatedButtonsSection(),

            const SizedBox(height: 24),

            // 悬浮卡片展示区
            _buildFloatingCardsSection(),

            const SizedBox(height: 24),

            // 呼吸动画展示区
            _buildBreathingAnimationSection(),

            const SizedBox(height: 100), // 为底部导航栏留空间
          ],
        ),
      ),

      // 毛玻璃底部导航栏
      bottomNavigationBar: GlassBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_rounded),
            label: '拍照',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco_rounded),
            label: '我的植物',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: '设置',
          ),
        ],
      ),

      // 灵动浮动按钮
      floatingActionButton: const AppleFAB(
        icon: Icons.add_rounded,
        gradientColors: AppThemes.appleGreenGradient,
      ),
    );
  }

  /// 渐变卡片展示区
  Widget _buildGradientCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '渐变卡片',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 16),

        // 蓝色渐变卡片
        AnimatedContainer2D(
          animationType: AnimationType.slideLeft,
          duration: const Duration(milliseconds: 800),
          child: const GradientCard(
            gradientColors: AppThemes.appleBlueGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 12),
                Text(
                  '智能识别',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'AI技术识别植物种类，提供专业养护建议',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 绿色渐变卡片
        AnimatedContainer2D(
          animationType: AnimationType.slideLeft,
          duration: const Duration(milliseconds: 1000),
          child: const GradientCard(
            gradientColors: AppThemes.appleGreenGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 12),
                Text(
                  '智能养护',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '根据植物特性提供个性化养护提醒',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 毛玻璃容器展示区
  Widget _buildGlassContainersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '毛玻璃效果',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 16),

        AnimatedContainer2D(
          animationType: AnimationType.combined,
          duration: const Duration(milliseconds: 1200),
          child: GlassContainer(
            child: Column(
              children: [
                const Icon(
                  Icons.blur_on_rounded,
                  color: Color(0xFF007AFF),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  '毛玻璃背景',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '半透明背景配合模糊效果，营造出苹果风格的层次感',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 动画按钮展示区
  Widget _buildAnimatedButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '灵动按钮',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: AnimatedContainer2D(
                animationType: AnimationType.scale,
                duration: const Duration(milliseconds: 600),
                child: DynamicButton(
                  text: '主要操作',
                  gradientColors: AppThemes.appleBlueGradient,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('点击了主要操作按钮')),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedContainer2D(
                animationType: AnimationType.scale,
                duration: const Duration(milliseconds: 800),
                child: DynamicButton(
                  text: '次要操作',
                  gradientColors: AppThemes.applePurpleGradient,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('点击了次要操作按钮')),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 悬浮卡片展示区
  Widget _buildFloatingCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '悬浮卡片',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: AnimatedContainer2D(
                animationType: AnimationType.slideUp,
                duration: const Duration(milliseconds: 1000),
                child: FloatingCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('点击了悬浮卡片')),
                    );
                  },
                  child: const Column(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFFF3B30),
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '收藏',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedContainer2D(
                animationType: AnimationType.slideUp,
                duration: const Duration(milliseconds: 1200),
                child: FloatingCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('点击了分享卡片')),
                    );
                  },
                  child: const Column(
                    children: [
                      Icon(
                        Icons.share_rounded,
                        color: Color(0xFF007AFF),
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '分享',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 呼吸动画展示区
  Widget _buildBreathingAnimationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '呼吸动画',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 16),

        Center(
          child: AnimatedBuilder(
            animation: AppleAnimations.createBreathingAnimation(_breathingController),
            builder: (context, child) {
              return Transform.scale(
                scale: AppleAnimations.createBreathingAnimation(_breathingController).value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppThemes.appleOrangeGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemes.appleOrangeGradient.first.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_florist_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
