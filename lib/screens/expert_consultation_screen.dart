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
import 'ai_expert_chat_screen.dart';
import 'dart:async';

class ExpertConsultationScreen extends StatefulWidget {
  const ExpertConsultationScreen({super.key});

  @override
  State<ExpertConsultationScreen> createState() => _ExpertConsultationScreenState();
}

class _ExpertConsultationScreenState extends State<ExpertConsultationScreen> {
  bool _isLoading = true;
  final _searchController = TextEditingController();
  int _selectedIndex = 0;

  // 专家列表数据
  final List<Map<String, dynamic>> _experts = [
    {
      'name': '张晓华',
      'avatar': 'assets/images/avatar/44.jpg',
      'specialty': '室内植物养护专家',
      'rating': 4.9,
      'reviewCount': 128,
      'price': 68,
      'availableTime': '今日 14:00-18:00',
      'experience': '8年',
      'description': '北京林业大学植物学硕士，专注于室内观叶植物的养护与繁殖研究，曾任某知名园艺公司技术总监，具有丰富的植物病害诊断与治疗经验。',
      'tags': ['观叶植物', '病害诊断', '养护方案'],
      'isOnline': true,
    },
    {
      'name': 'Liam van Dijk',
      'avatar': 'assets/images/avatar/32.jpg',
      'specialty': '花卉栽培专家',
      'rating': 4.7,
      'reviewCount': 95,
      'price': 58,
      'availableTime': '明日 10:00-20:00',
      'experience': '12年',
      'description': '荷兰瓦赫宁根大学博士，主攻花卉栽培与遗传育种方向，现任某植物园技术顾问，对各类花卉的生长特性、栽培技术及常见问题有深入研究。',
      'tags': ['花卉栽培', '品种选择', '开花技巧'],
      'isOnline': false,
    },
    {
      'name': 'Fiona Wang',
      'avatar': 'assets/images/avatar/68.jpg',
      'specialty': '多肉植物专家',
      'rating': 4.8,
      'reviewCount': 156,
      'price': 49,
      'availableTime': '今日 09:00-21:00',
      'experience': '6年',
      'description': '美国康奈尔大学农业与生命科学学院资深研究员，多肉植物爱好者，自建多肉植物网站与专栏作者，著有《多肉植物养护指南》一书，对多肉植物的品种、繁殖与日常管理有丰富经验。',
      'tags': ['多肉植物', '组合盆栽', '光照管理'],
      'isOnline': true,
    },
    {
      'name': '赵强',
      'avatar': 'assets/images/avatar/15.jpg',
      'specialty': '园林植物专家',
      'rating': 4.6,
      'reviewCount': 87,
      'price': 78,
      'availableTime': '今日 16:00-20:00',
      'experience': '15年',
      'description': '园林工程师，从事园林规划设计与植物配置工作多年，对庭院植物景观设计、植物选择与养护有独到见解，擅长解决各类庭院植物问题。',
      'tags': ['庭院植物', '景观设计', '病虫害防治'],
      'isOnline': false,
    },
    {
      'name': '刘婷',
      'avatar': 'assets/images/avatar/48.jpg',
      'specialty': '兰花栽培专家',
      'rating': 5.0,
      'reviewCount': 67,
      'price': 88,
      'availableTime': '明日 13:00-17:00',
      'experience': '10年',
      'description': '中国兰花协会会员，专注兰花栽培与研究，多次获得兰花展览奖项，对各类兰花的品种特性、生长环境需求及繁殖技术有深入研究。',
      'tags': ['兰花栽培', '品种鉴赏', '繁殖技术'],
      'isOnline': true,
    },
    {
      'name': '若葉 睦',
      'avatar': 'assets/images/avatar/mumu.png',
      'specialty': '黄瓜种植专家',
      'rating': 9.9,
      'reviewCount': 103,
      'price': 648,
      'availableTime': '今日 08:00-23:00',
      'experience': '15年',
      'description': '月之森女子学园园艺部高级部员，专注黄瓜栽培与育种研究，多次参与Bushiroadキュウリ品种展示与评比并获多项荣誉，对各类黄瓜品种的特性、生长习性及高效栽培技术有深入系统的研究。',
      'tags': ['黄瓜'],
      'isOnline': true,
    },
  ];

  // 分类标签
  final List<String> _categories = [
    '全部专家',
    '室内植物',
    '花卉栽培',
    '多肉植物',
    '庭院园艺',
    '兰花专家',
    '病虫害防治',
  ];

  @override
  void initState() {
    super.initState();

    // 模拟加载
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: '专家咨询',
      ),
      body: ParticleBackground(
        particleCount: 30,
        particleColor: Colors.orange.withValues(alpha: 0.2),
        particleSize: 1.8,
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
        title: const Text('专家咨询'),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isDynamic) ...[
            AnimatedContainer2D(
              animationType: AnimationType.combined,
              duration: const Duration(seconds: 1),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF9800),
                      Color(0xFFFF5722),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ] else ...[
            const CircularProgressIndicator(
              color: Colors.orange,
            ),
          ],

          const SizedBox(height: 24),

          Text(
            '正在为您筛选专业植物专家...',
            style: TextStyle(
              fontSize: 16,
              color: isDynamic ? Colors.orange : null,
            ),
          ),
        ],
      ),
    );
  }

  // 搜索栏
  Widget _buildSearchBar(bool isDynamic) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDynamic
            ? Colors.black.withValues(alpha: 0.4) // 加深背景色以增强对比度
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDynamic
              ? Colors.white.withValues(alpha: 0.5) // 加深边框颜色增强对比度
              : Colors.grey[300]!,
          width: isDynamic ? 1.5 : 1, // 增加边框宽度
        ),
        boxShadow: isDynamic
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: isDynamic ? Colors.black : null, // 确保文本是纯白色
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
          hintText: '搜索专家名称、专业领域',
          hintStyle: TextStyle(
            color: isDynamic
                ? Colors.white.withValues(alpha: 0.7) // 提高提示文字的不透明度
                : Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDynamic
                ? Colors.white // 使用纯白色图标
                : Colors.grey[500],
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.filter_list,
              color: isDynamic
                  ? Colors.white // 使用纯白色图标
                  : Colors.grey[600],
            ),
            onPressed: () {
              // TODO: 显示筛选选项
            },
          ),
        ),
      ),
    );
  }

  // 分类标签
  Widget _buildCategoryTabs(bool isDynamic) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final isSelected = _selectedIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDynamic ? const Color(0xFFFF9800) : Theme.of(context).colorScheme.primary)
                  : (isDynamic ? Colors.black.withValues(alpha: 0.4) : Colors.grey[100]), // 加深非选中标签的背景色
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? (isDynamic ? const Color(0xFFFF9800) : Theme.of(context).colorScheme.primary)
                    : (isDynamic ? Colors.white.withValues(alpha: 0.5) : Colors.grey[300]!), // 加深非选中标签的边框颜色
                width: isDynamic ? 1.5 : 1, // 增加边框宽度
              ),
              boxShadow: isSelected && isDynamic
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              _categories[index],
              style: TextStyle(
                color: isSelected
                    ? (isDynamic ? Colors.white : Colors.white)
                    : (isDynamic ? Colors.white : Colors.grey[800]),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  // 主内容区域
  Widget _buildMainContent(bool isDynamic) {
    return Column(
      children: [
        // 搜索和筛选区域
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _buildSearchBar(isDynamic),
        ),

        // 分类标签
        SizedBox(
          height: 48,
          child: _buildCategoryTabs(isDynamic),
        ),

        // 专家列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _experts.length,
            itemBuilder: (context, index) {
              return _buildExpertCard(_experts[index], isDynamic);
            },
          ),
        ),

        // AI 专家解答入口
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDynamic ? Colors.black.withValues(alpha: 0.6) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDynamic ? Colors.black.withValues(alpha: 0.2) : Colors.grey[300]!,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AiExpertChatScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.smart_toy,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '免费AI专家解答',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDynamic ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.green,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 专家卡片
  Widget _buildExpertCard(Map<String, dynamic> expert, bool isDynamic) {
    final cardColor = isDynamic
        ? Colors.black.withValues(alpha: 0.5) // 加深卡片背景色
        : Colors.white;

    final borderColor = isDynamic
        ? Colors.orange.withValues(alpha: 0.5) // 加深边框颜色
        : Colors.grey[200]!;

    final shadowColor = isDynamic
        ? Colors.orange.withValues(alpha: 0.3) // 加深阴影颜色
        : Colors.black.withValues(alpha: 0.05);

    return GestureDetector(
      onTap: () {
        _showExpertDetailSheet(context, expert, isDynamic);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isDynamic ? 1.5 : 1, // 增加边框宽度
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: isDynamic ? 15 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // 专家头部信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 头像
                  Stack(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDynamic
                                ? Colors.orange // 使用纯橙色边框
                                : Colors.orange[200]!,
                            width: isDynamic ? 2.5 : 2, // 增加边框宽度
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: isDynamic ? 0.4 : 0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            expert['avatar'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (expert['isOnline'])
                        Positioned(
                          right: 0,
                          bottom: 5,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDynamic ? Colors.black : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // 专家信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              expert['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDynamic ? Colors.white : Colors.black87, // 使用纯白色
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: isDynamic ? Colors.orange : Colors.blue,
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          expert['specialty'],
                          style: TextStyle(
                            fontSize: 14,
                            color: isDynamic
                                ? Colors.white // 使用纯白色增强可读性
                                : Colors.grey[700],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              expert['rating'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDynamic ? Colors.white : Colors.black87, // 使用纯白色
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '(${expert['reviewCount']}条评价)',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDynamic
                                    ? Colors.white.withValues(alpha: 0.8) // 提高透明度
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 价格标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.4), // 增加阴影透明度
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '¥${expert['price']}/次',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 专家标签
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 时间信息
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: isDynamic
                            ? Colors.orange // 使用纯橙色
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expert['availableTime'],
                        style: TextStyle(
                          fontSize: 13,
                          color: isDynamic
                              ? Colors.white // 使用纯白色
                              : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.work_outline,
                        size: 16,
                        color: isDynamic
                            ? Colors.orange // 使用纯橙色
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '从业${expert['experience']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDynamic
                              ? Colors.white // 使用纯白色
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 专业标签
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (expert['tags'] as List<String>).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDynamic
                              ? Colors.orange.withValues(alpha: 0.3) // 加深背景色
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDynamic
                                ? Colors.orange.withValues(alpha: 0.6) // 加深边框色
                                : Colors.orange[200]!,
                            width: isDynamic ? 1.5 : 1, // 增加边框宽度
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDynamic ? Colors.white : Colors.orange[800], // 使用纯白色
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // 按钮区域
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showReservationDialog(context, expert, isDynamic);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDynamic ? Colors.orange : null,
                            foregroundColor: isDynamic ? Colors.white : null,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text('预约咨询'),
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

  // 显示专家详情底部弹窗
  void _showExpertDetailSheet(BuildContext context, Map<String, dynamic> expert, bool isDynamic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许更大的高度
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDynamic ? Colors.black.withValues(alpha: 0.9) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // 顶部拖动条
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDynamic ? Colors.white38 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // 专家信息
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // 头像和基本信息
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDynamic ? Colors.orange : Colors.orange[300]!,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              expert['avatar'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.person, size: 60, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    expert['name'],
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDynamic ? Colors.white : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.verified,
                                    size: 20,
                                    color: isDynamic ? Colors.orange : Colors.blue,
                                  ),
                                  if (expert['isOnline']) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        '在线',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                expert['specialty'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDynamic ? Colors.white70 : Colors.grey[700],
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${expert['rating']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDynamic ? Colors.white : null,
                                    ),
                                  ),
                                  Text(
                                    ' (${expert['reviewCount']}条评价)',
                                    style: TextStyle(
                                      color: isDynamic ? Colors.white60 : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 专家简介
                    Text(
                      '专家简介',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDynamic ? Colors.white : null,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      expert['description'],
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: isDynamic ? Colors.white70 : Colors.grey[800],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 专业领域
                    Text(
                      '专业领域',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDynamic ? Colors.white : null,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: (expert['tags'] as List<String>).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDynamic
                                ? Colors.orange.withValues(alpha: 0.15)
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDynamic
                                  ? Colors.orange.withValues(alpha: 0.3)
                                  : Colors.orange[300]!,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isDynamic ? Colors.orange[200] : Colors.orange[800],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 可预约时间
                    Text(
                      '可预约时间',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDynamic ? Colors.white : null,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDynamic
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDynamic
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: isDynamic ? Colors.orange[300] : Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expert['availableTime'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDynamic ? Colors.white : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '预约后可获得30分钟的一对一视频咨询',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDynamic ? Colors.white60 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 用户评价
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '用户评价',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDynamic ? Colors.white : null,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            '查看全部 >',
                            style: TextStyle(
                              color: isDynamic ? Colors.orange[300] : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 模拟评价
                    _buildReviewItem(
                      name: '李**',
                      avatar: 'assets/images/avatar/anon_t.png',
                      rating: 5.0,
                      date: '2025-06-28',
                      content: '非常专业的建议，解决了我家绿萝叶子发黄的问题，谢谢专家！',
                      isDynamic: isDynamic,
                    ),

                    const Divider(height: 32),

                    _buildReviewItem(
                      name: '丰川**',
                      avatar: 'assets/images/avatar/saki_p.png',
                      rating: 4.5,
                      date: '2025-06-25',
                      content: '咨询过程很愉快，专家很耐心地解答了我所有问题，提供了很多有用的建议。',
                      isDynamic: isDynamic,
                    ),
                  ],
                ),
              ),

              // 底部预约按钮
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDynamic ? Colors.black : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '咨询价格',
                          style: TextStyle(
                            color: isDynamic ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '¥${expert['price']}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDynamic ? Colors.orange : Colors.orange[700],
                              ),
                            ),
                            Text(
                              ' /次',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDynamic ? Colors.white60 : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showReservationDialog(context, expert, isDynamic);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          '立即预约',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 用户评价项
  Widget _buildReviewItem({
    required String name,
    required String avatar,
    required double rating,
    required String date,
    required String content,
    required bool isDynamic,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 头像
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDynamic
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey[300]!,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.grey[500]),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 姓名和评分
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDynamic ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < rating
                              ? (index + 0.5 == rating ? Icons.star_half : Icons.star)
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDynamic ? Colors.white60 : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 评价内容
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isDynamic ? Colors.white70 : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  // 显示预约对话框
  void _showReservationDialog(BuildContext context, Map<String, dynamic> expert, bool isDynamic) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDynamic
              ? Colors.black.withValues(alpha: 0.9)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Text(
                  '预约咨询',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDynamic ? Colors.white : Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // 专家信息
                Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        expert['avatar'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: Icon(Icons.person, color: Colors.grey[500]),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expert['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDynamic ? Colors.white : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expert['specialty'],
                            style: TextStyle(
                              fontSize: 14,
                              color: isDynamic ? Colors.white70 : Colors
                                  .grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 价格信息
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDynamic
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDynamic
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '咨询服务费',
                        style: TextStyle(
                          color: isDynamic ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '¥${expert['price']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDynamic ? Colors.orange[300] : Colors
                                  .orange[700],
                            ),
                          ),
                          Text(
                            '/次',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDynamic ? Colors.white60 : Colors
                                  .grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 预约时间
                Text(
                  '可预约时间',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDynamic ? Colors.white : null,
                  ),
                  textAlign: TextAlign.left,
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDynamic
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDynamic
                          ? Colors.orange.withValues(alpha: 0.3)
                          : Colors.orange[300]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert['availableTime'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDynamic ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '30分钟视频咨询',
                        style: TextStyle(
                          color: isDynamic ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 按钮
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: isDynamic ? Colors.white70 : null,
                        ),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showReservationSuccess(context, expert, isDynamic);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('确认预约'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 显示预约成功对话框
  void _showReservationSuccess(BuildContext context, Map<String, dynamic> expert, bool isDynamic) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDynamic ? Colors.black.withValues(alpha: 0.9) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 成功图标
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  '预约成功',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDynamic ? Colors.white : Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '您已成功预约${expert['name']}的咨询服务',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDynamic ? Colors.white70 : Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDynamic
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildReservationInfoRow(
                        icon: Icons.person,
                        label: '专家',
                        value: expert['name'],
                        isDynamic: isDynamic,
                      ),
                      const SizedBox(height: 8),
                      _buildReservationInfoRow(
                        icon: Icons.access_time,
                        label: '预约时间',
                        value: expert['availableTime'],
                        isDynamic: isDynamic,
                      ),
                      const SizedBox(height: 8),
                      _buildReservationInfoRow(
                        icon: Icons.videocam,
                        label: '咨询方式',
                        value: '视频咨询',
                        isDynamic: isDynamic,
                      ),
                      const SizedBox(height: 8),
                      _buildReservationInfoRow(
                        icon: Icons.payment,
                        label: '咨询费用',
                        value: '¥${expert['price']}',
                        isDynamic: isDynamic,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text('完成'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 预约信息行
  Widget _buildReservationInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDynamic,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDynamic ? Colors.white60 : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label：',
          style: TextStyle(
            color: isDynamic ? Colors.white70 : Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDynamic ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
