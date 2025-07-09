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
import 'dart:math' as math;

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _loadingAnimation;

  // 文章分类
  final List<String> _categories = [
    '推荐',
    '求助',
    '分享',
    '讨论',
    '炫耀',
    '最新',
  ];

  // 模拟的帖子数据
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'type': '求助',
      'title': '我的龟背竹叶子发黄，怎么办？',
      'username': '种菜新手123',
      // 'avatar': 'https://randomuser.me/api/portraits/women/32.jpg',
      'avatar': 'assets/images/avatar/anon.png',
      'content': '刚养了一盆龟背竹，最近发现底部叶子开始发黄，边缘还有点焦枯。我每周浇水一次，放在朝北的窗户边。是水浇多了还是光照不足？求大神指点！',
      'images': [
        'assets/images/plantpic/comment/Monsteradeliciosa.jpg',
      ],
      'likeCount': 42,
      'commentCount': 15,
      'createdAt': '2小时前',
      'comments': [
        {
          'username': 'GreenThumb42',
          // 'avatar': 'https://randomuser.me/api/portraits/men/42.jpg',
          'avatar': 'assets/images/avatar/mumu.png',
          'content': '可能是浇水过多，龟背竹喜欢湿润但不积水，试试等土壤干透再浇。',
          'likeCount': 8,
          'createdAt': '1小时前'
        },
        {
          'username': 'JungleQueen',
          // 'avatar': 'https://randomuser.me/api/portraits/women/21.jpg',
          'avatar': 'assets/images/avatar/nya.png',
          'content': '北窗光线可能不够，可以挪到有散射光的地方，避免阳光直射。',
          'likeCount': 12,
          'createdAt': '40分钟前'
        }
      ],
      'isLiked': false,
      'isBookmarked': false,
    },
    {
      'id': '2',
      'type': '分享',
      'title': '我的多肉终于开花了！',
      'username': '持石爱好者Tomori',
      // 'avatar': 'https://randomuser.me/api/portraits/men/35.jpg',
      'avatar': 'assets/images/avatar/tomori.png',
      'content': '养了两年多的多肉，今天突然发现它开花了！小小的粉色花朵，超级可爱。分享一下养护心得：少浇水、多阳光，冬天控温10°C以上。',
      'images': [
        'assets/images/plantpic/comment/bfj.png',
        'assets/images/plantpic/comment/phy.png',
      ],
      'likeCount': 78,
      'commentCount': 8,
      'createdAt': '4小时前',
      'comments': [
        {
          'username': 'CactusFan',
          // 'avatar': 'https://randomuser.me/api/portraits/women/42.jpg',
          'avatar': 'assets/images/avatar/mmk_p3.png',
          'content': '恭喜！我的多肉从来没开过花，羡慕！',
          'likeCount': 3,
          'createdAt': '3小时前'
        },
        {
          'username': 'PlantDoc',
          // 'avatar': 'https://randomuser.me/api/portraits/men/18.jpg',
          'avatar': 'assets/images/avatar/soyo_p2.png',
          'content': '开花说明养护得很好，但开花后可能会消耗养分，记得适当补充肥料。',
          'likeCount': 15,
          'createdAt': '2小时前'
        }
      ],
      'isLiked': true,
      'isBookmarked': false,
    },
    {
      'id': '3',
      'type': '讨论',
      'title': '大家用什么肥料？有机 vs. 化学',
      'username': 'EcoGardener, 毋畏遗忘',
      // 'avatar': 'https://randomuser.me/api/portraits/women/45.jpg',
      'avatar': 'assets/images/avatar/saki.png',
      'content': '我一直用自制的堆肥，但朋友推荐化学肥料见效快。想听听大家的经验，哪种对植物更好？',
      'images': [],
      'likeCount': 52,
      'commentCount': 34,
      'createdAt': '昨天',
      'comments': [
        {
          'username': 'OrganicOnly',
          // 'avatar': 'https://randomuser.me/api/portraits/men/28.jpg',
          'avatar': 'assets/images/avatar/nina_p1.png',
          'content': '有机肥长期更健康，不会烧根，还能改善土壤。',
          'likeCount': 22,
          'createdAt': '20小时前'
        },
        {
          'username': '听着空之箱飙车的SpeedGrow',
          // 'avatar': 'https://randomuser.me/api/portraits/men/53.jpg',
          'avatar': 'assets/images/avatar/mmk_p2.png',
          'content': '化学肥快速有效，但要注意用量，过量会伤植物。',
          'likeCount': 18,
          'createdAt': '18小时前'
        }
      ],
      'isLiked': false,
      'isBookmarked': true,
    },
    {
      'id': '4',
      'type': '求助',
      'title': '绿萝长藤但不长新叶，正常吗？',
      'username': 'VineWatcher',
      // 'avatar': 'https://randomuser.me/api/portraits/women/75.jpg',
      'avatar': 'assets/images/avatar/hl.png',
      'content': '我的绿萝藤蔓越来越长，但最近几个月几乎没长新叶子。是缺养分还是该修剪了？',
      'images': [
        'assets/images/plantpic/comment/lvl.png',
      ],
      'likeCount': 37,
      'commentCount': 12,
      'createdAt': '3天前',
      'comments': [
        {
          'username': 'PruneMaster',
          // 'avatar': 'https://randomuser.me/api/portraits/men/64.jpg',
          'avatar': 'assets/images/avatar/delta.png',
          'content': '可以适当修剪藤蔓，促进侧芽生长。',
          'likeCount': 8,
          'createdAt': '2天前'
        },
        {
          'username': 'PlantFoodie, 糖分还不够',
          // 'avatar': 'https://randomuser.me/api/portraits/women/26.jpg',
          'avatar': 'assets/images/avatar/anon_p.png',
          'content': '试试加点氮肥，可能缺营养了。',
          'likeCount': 14,
          'createdAt': '1天前'
        }
      ],
      'isLiked': true,
      'isBookmarked': false,
    },
    {
      'id': '5',
      'type': '炫耀',
      'title': '月之森校园园艺部的小花园！',
      'username': '若葉 睦',
      'avatar': 'assets/images/avatar/mu.png',
      'content': '经过半年努力，终于实现了这个迷你花园！有黄瓜、番茄「キュウリ」、茄子「キュウリ」，还有一盆小黄瓜。每天看着它们心情超好的～',
      'images': [
        'assets/images/plantpic/comment/kyuuri.jpg',
        'assets/images/plantpic/comment/kyuuri2.png',
        'assets/images/plantpic/comment/kyuuri3.png',
        'assets/images/plantpic/comment/mu.png',
      ],
      'likeCount': 127,
      'commentCount': 23,
      'createdAt': '1周前',
      'comments': [
        {
          'username': 'Taki Shiina (Rikki)',
          'avatar': 'assets/images/avatar/hl.png',
          'content': '太美了！我也在规划种植，求推荐易养的石头和企鹅。',
          'likeCount': 6,
          'createdAt': '6天前'
        },
        {
          'username': 'HerbExpert',
          'avatar': 'assets/images/avatar/nya.png',
          'content': '黄瓜超级适合新手，耐折腾！',
          'likeCount': 10,
          'createdAt': '5天前'
        },
        {
          'username': '东京Anon',
          'avatar': 'assets/images/avatar/anon_t.png',
          'content': '她用勤劳的双手种植黄瓜，供养着一家人。每天天刚蒙蒙亮，她便起身走进田地，感受着泥土的温度，检查每一株黄瓜苗的生长情况。今年的天气反常，时而暴雨，时而干旱，让黄瓜的成长充满挑战。但若叶睦没有放弃，她每天细心浇水、施肥，用心呵护着每一片叶子。村里的孩子们—Soyo、Saki 和灯—常常跑到田地里看她劳动，她们喜欢这位和善的老农民，尤其是Soyo，她总是跟在若叶睦身后，睁着大眼睛看着黄瓜如何一天天长大。一天夜里，一场突如其来的暴风雨袭来，田里的黄瓜苗被狂风吹得东倒西歪，许多枝蔓被折断。若叶睦冒着大雨跑进田里，她用双手扶起倒下的藤蔓，用木棍支撑起受损的植株，眼神中满是心疼。Soyo、Saki 和灯也赶来帮忙，孩子们用稚嫩的手小心翼翼地把泥土轻轻拍实，生怕伤到黄瓜苗。经过连夜的努力，虽然有些黄瓜苗已经无法挽救，但剩下的植株终于挺了过来。第二天清晨，阳光洒在田地里，露珠在黄瓜叶上闪烁着希望的光芒。Soyo欣喜地发现，有几株黄瓜依然顽强地挂在藤蔓上，她激动地对若叶睦喊道：“它们还活着呢！”若叶睦抹了抹额头的汗水，欣慰地笑了。她知道，只要不放弃，黄瓜终会结出累累果实。到了丰收的季节，田地里挂满了翠绿的黄瓜，Soyo、Saki和灯兴奋地帮忙采摘。她们把新鲜的黄瓜送给村里的邻居，每个人的脸上都洋溢着幸福的笑容。这片田地不仅种出了甘甜的黄瓜，更种下了希望、坚持和爱。',
          'likeCount': 42,
          'createdAt': '3小时前'
        }
      ],
      'isLiked': true,
      'isBookmarked': true,
    },
    {
      'id': '6',
      'type': '求助',
      'title': '仙人掌为什么突然枯萎了？我明明没做错什么！',
      'username': '刺刺のNina',
      'avatar': 'assets/images/avatar/nina_p2.png',
      'content': '养了三个月的仙人掌，最近开始发软变黄。我按照教程每周只浇一点点水，放在窗边有阳光的地方。明明什么都没做错，为什么它会这样？是不是和学校那群人一样在针对我？（注：花盆是hina去年送的，但和这个没关系！）',
      'images': [
        'assets/images/plantpic/comment/xrz.png',
        'assets/images/plantpic/comment/nina2.png',
        'assets/images/plantpic/comment/mmk.png',
        'assets/images/plantpic/comment/nina.png',
      ],
      'likeCount': 103,
      'commentCount': 6,
      'createdAt': '1刺分钟前',
      'comments': [
        {
          'username': '退休鼓手MMK',
          'avatar': 'assets/images/avatar/mmk_p1.png',
          'content': '你窗边是西晒吧？仙人掌晒伤了。另外，那个花盆没排水孔，根可能烂了。和你一样，总是一根筋地冲，但方向错了。',
          'likeCount': 27,
          'createdAt': '25刺秒前'
        },
        {
          'username': '并非演员安和昴',
          'avatar': 'assets/images/avatar/486_p.png',
          'content': '仁仁菜～先换个透气陶盆！土也要换成沙质的。需要的话，我这周末陪你去花市？（悄悄说：我奶奶教过我配土，比演戏简单多了w）',
          'likeCount': 486,
          'createdAt': '21刺秒前'
        },
        {
          'username': '匿名用户',
          'avatar': 'assets/images/avatar/miao.png',
          'content': '浇水频率没问题，但建议用牙签测土壤湿度。另外，负面情绪会影响植物哦。',
          'likeCount': 42,
          'createdAt': '17刺秒前'
        },
        {
          'username': 'Type_Tomo',
          'avatar': 'assets/images/avatar/tomo1.png',
          'content': '你连仙人掌都能养死？先别急着找原因，查查是不是土太保水了。还有……别把情绪带进种花里。',
          'likeCount': 36,
          'createdAt': '7刺秒前'
        },
        {
          'username': 'AshenChord',
          'avatar': 'assets/images/avatar/rupa.png',
          'content': '仙人掌不是娇气的植物，它活下来靠的是环境，不是你。你给的阳光可能太多，也可能太少。就像我们乐队一样，不是谁想红就能红……但只要活着，就有意义。『承認も義務も、どちらも関係ない。』',
          'likeCount': 21,
          'createdAt': '3刺秒前'
        },
        {
          'username': '咕咕嘎嘎? 咕咕嘎嘎!',
          'avatar': 'assets/images/avatar/gugugaga.png',
          'content': 'gu gu ga ga! 🐧🐧🐧',
          'likeCount': 3,
          'createdAt': '0.5刺秒前'
        }
      ],
      'isLiked': true,
      'isBookmarked': true,
    }
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _loadingAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
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
        title: '社区问答',
      ),
      body: ParticleBackground(
        particleCount: 25,
        particleColor: Colors.green.withValues(alpha: 0.2),
        particleSize: 1.5,
        child: _isLoading
            ? _buildLoadingView(true)
            : _buildForumContent(true),
      ),
      floatingActionButton: AnimatedContainer2D(
        animationType: AnimationType.scale,
        duration: const Duration(milliseconds: 400),
        child: FloatingActionButton(
          onPressed: () {
            _showCreatePostDialog(context, true);
          },
          backgroundColor: Colors.green,
          elevation: 8,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  // 简约主题版本
  Widget _buildMinimalScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区问答'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? _buildLoadingView(false)
          : _buildForumContent(false),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog(context, false);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 加载视图
  Widget _buildLoadingView(bool isDynamic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isDynamic) ...[
            AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _loadingAnimation.value * 2 * math.pi / 5,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4CAF50),
                          Color(0xFF8BC34A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.forum,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
          ] else ...[
            const CircularProgressIndicator(
              color: Colors.green,
            ),
          ],

          const SizedBox(height: 24),

          Text(
            '正在加载社区内容...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDynamic ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  // 主要内容区域
  Widget _buildForumContent(bool isDynamic) {
    return Column(
      children: [
        // 搜索栏
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _buildSearchBar(isDynamic),
        ),

        // 分类标签
        SizedBox(
          height: 44,
          child: _buildCategoryTabs(isDynamic),
        ),

        // 帖子列表
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // 模拟刷新操作
              setState(() {
                _isLoading = true;
              });

              await Future.delayed(const Duration(seconds: 1));

              setState(() {
                _isLoading = false;
              });
            },
            color: isDynamic ? Colors.white : Colors.green,
            backgroundColor: isDynamic ? Colors.green : null,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(_posts[index], isDynamic);
              },
            ),
          ),
        ),
      ],
    );
  }

  // 搜索栏
  Widget _buildSearchBar(bool isDynamic) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDynamic
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDynamic
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.grey[300]!,
          width: isDynamic ? 1.5 : 1,
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
          color: isDynamic ? Colors.white : null,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
          hintText: '搜索植物问题、养护技巧...',
          hintStyle: TextStyle(
            color: isDynamic
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDynamic
                ? Colors.white
                : Colors.grey[500],
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.filter_list,
              color: isDynamic
                  ? Colors.white
                  : Colors.grey[600],
            ),
            onPressed: () {
              // 显示筛选选项
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
        final isSelected = _selectedCategoryIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategoryIndex = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDynamic ? Colors.green : Theme.of(context).colorScheme.primary)
                  : (isDynamic ? Colors.black.withValues(alpha: 0.3) : Colors.grey[100]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? (isDynamic ? Colors.green : Theme.of(context).colorScheme.primary)
                    : (isDynamic ? Colors.white.withValues(alpha: 0.4) : Colors.grey[300]!),
                width: isDynamic ? 1.5 : 1,
              ),
              boxShadow: isSelected && isDynamic
                  ? [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
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

  // 帖子卡片
  Widget _buildPostCard(Map<String, dynamic> post, bool isDynamic) {
    final cardColor = isDynamic
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.white;

    final borderColor = isDynamic
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.grey[200]!;

    final shadowColor = isDynamic
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.05);

    return GestureDetector(
      onTap: () {
        _navigateToPostDetail(context, post, isDynamic);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isDynamic ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: isDynamic ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 帖子头部信息
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // 类型标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(post['type']).withValues(alpha: isDynamic ? 0.3 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getTypeColor(post['type']).withValues(alpha: isDynamic ? 0.6 : 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      post['type'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDynamic ? _getTypeColor(post['type']) : _getTypeColor(post['type']),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 用户信息
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDynamic ? Colors.white.withValues(alpha: 0.6) : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: _buildImageWidget(
                        post['avatar'],
                        isDynamic: isDynamic,
                        width: 24,
                        height: 24
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  Text(
                    post['username'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isDynamic ? Colors.white.withValues(alpha: 0.9) : Colors.grey[700],
                    ),
                  ),

                  const Spacer(),

                  // 发布时间
                  Text(
                    post['createdAt'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDynamic ? Colors.white.withValues(alpha: 0.6) : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // 帖子标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                post['title'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDynamic ? Colors.white : Colors.black87,
                ),
              ),
            ),

            // 帖子内容
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                post['content'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isDynamic ? Colors.white.withValues(alpha: 0.8) : Colors.grey[800],
                ),
              ),
            ),

            // 帖子图片
            if ((post['images'] as List).isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  itemCount: (post['images'] as List).length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 180,
                      height: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDynamic ? Colors.white.withValues(alpha: 0.3) : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: _buildImageWidget(
                          post['images'][index],
                          isDynamic: isDynamic,
                          width: 180,
                          height: 120
                        ),
                      ),
                    );
                  },
                ),
              ),

            if ((post['images'] as List).isNotEmpty)
              const SizedBox(height: 12),

            // 底部互动区域
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  // 点赞按钮
                  _buildInteractionButton(
                    icon: Icons.thumb_up,
                    label: post['likeCount'].toString(),
                    isActive: post['isLiked'],
                    isDynamic: isDynamic,
                    activeColor: Colors.blue,
                    onTap: () {
                      setState(() {
                        post['isLiked'] = !post['isLiked'];
                        post['likeCount'] += post['isLiked'] ? 1 : -1;
                      });
                    },
                  ),

                  const SizedBox(width: 24),

                  // 评论按钮
                  _buildInteractionButton(
                    icon: Icons.comment,
                    label: post['commentCount'].toString(),
                    isActive: false,
                    isDynamic: isDynamic,
                    activeColor: Colors.green,
                    onTap: () {
                      _navigateToPostDetail(context, post, isDynamic);
                    },
                  ),

                  const Spacer(),

                  // 收藏按钮
                  IconButton(
                    onPressed: () {
                      setState(() {
                        post['isBookmarked'] = !post['isBookmarked'];
                      });
                    },
                    icon: Icon(
                      post['isBookmarked'] ? Icons.bookmark : Icons.bookmark_border,
                      size: 22,
                      color: post['isBookmarked']
                          ? (isDynamic ? Colors.amber : Colors.amber[700])
                          : (isDynamic ? Colors.white.withValues(alpha: 0.8) : Colors.grey[600]),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  const SizedBox(width: 16),

                  // 分享按钮
                  IconButton(
                    onPressed: () {
                      // 分享功能
                    },
                    icon: Icon(
                      Icons.share,
                      size: 20,
                      color: isDynamic ? Colors.white.withValues(alpha: 0.8) : Colors.grey[600],
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 辅助方法：根据路径判断加载网络图片还是本地图片
  Widget _buildImageWidget(String path, {bool isDynamic = false, double? width, double? height}) {
    if (path.startsWith('http')) {
      // 网络图片
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: isDynamic ? Colors.black.withValues(alpha: 0.2) : Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: isDynamic ? Colors.green : Colors.blue,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: isDynamic ? Colors.black.withValues(alpha: 0.3) : Colors.grey[200],
            child: Icon(
              Icons.image_not_supported,
              color: isDynamic ? Colors.white.withValues(alpha: 0.6) : Colors.grey,
              size: (width != null && height != null)
                ? (width < height ? width * 0.4 : height * 0.4).clamp(20.0, 40.0)
                : 40,
            ),
          );
        },
      );
    } else {
      // 本地资产图片
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: isDynamic ? Colors.black.withValues(alpha: 0.3) : Colors.grey[200],
            child: Icon(
              Icons.image_not_supported,
              color: isDynamic ? Colors.white.withValues(alpha: 0.6) : Colors.grey,
              size: (width != null && height != null)
                ? (width < height ? width * 0.4 : height * 0.4).clamp(20.0, 40.0)
                : 40,
            ),
          );
        },
      );
    }
  }

  // 互动按钮（点赞、评论等）
  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDynamic,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive
                ? (isDynamic ? activeColor : activeColor)
                : (isDynamic ? Colors.white.withValues(alpha: 0.8) : Colors.grey[600]),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? (isDynamic ? activeColor : activeColor)
                  : (isDynamic ? Colors.white.withValues(alpha: 0.8) : Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  // 获取不同类型帖子的颜色
  Color _getTypeColor(String type) {
    switch (type) {
      case '求助':
        return Colors.red.shade200;
      case '分享':
        return Colors.blue.shade200;
      case '讨论':
        return Colors.purple.shade200;
      case '炫耀':
        return Colors.green.shade200;
      default:
        return Colors.grey;
    }
  }

  // 跳转到帖子详情
  void _navigateToPostDetail(BuildContext context, Map<String, dynamic> post, bool isDynamic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildPostDetailSheet(context, post, isDynamic);
      },
    );
  }

  // 帖子详情底部弹窗
  Widget _buildPostDetailSheet(BuildContext context, Map<String, dynamic> post, bool isDynamic) {
    final mediaQuery = MediaQuery.of(context);
    final commentController = TextEditingController();

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: isDynamic ? Colors.black.withValues(alpha: 0.95) : Colors.white,
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

          // 主要内容
          Expanded(
            child: CustomScrollView(
              slivers: [
                // 帖子详情
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 帖子头部信息
                        Row(
                          children: [
                            // 用户头像
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDynamic ? Colors.white.withValues(alpha: 0.6) : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: _buildImageWidget(
                                  post['avatar'],
                                  isDynamic: isDynamic,
                                  width: 50,
                                  height: 50
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 用户信息和时间
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['username'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDynamic ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    post['createdAt'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDynamic ? Colors.white.withValues(alpha: 0.6) : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 类型标签
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getTypeColor(post['type']).withValues(alpha: isDynamic ? 0.3 : 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _getTypeColor(post['type']).withValues(alpha: isDynamic ? 0.6 : 0.3),
                                ),
                              ),
                              child: Text(
                                post['type'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDynamic ? _getTypeColor(post['type']) : _getTypeColor(post['type']),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 帖子标题
                        Text(
                          post['title'],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDynamic ? Colors.white : Colors.black,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 帖子内容
                        Text(
                          post['content'],
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: isDynamic ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 帖子图片
                        if ((post['images'] as List).isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              (post['images'] as List).length,
                              (index) => GestureDetector(
                                onTap: () {
                                  // 图片查看器
                                },
                                child: Container(
                                  width: (mediaQuery.size.width - 56) / 2,
                                  height: (mediaQuery.size.width - 56) / 2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDynamic ? Colors.white.withValues(alpha: 0.3) : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: _buildImageWidget(
                                      post['images'][index],
                                      isDynamic: isDynamic,
                                      width: (mediaQuery.size.width - 56) / 2,
                                      height: (mediaQuery.size.width - 56) / 2
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],

                        // 互动区域
                        Row(
                          children: [
                            // 点赞按钮
                            _buildInteractionButton(
                              icon: Icons.thumb_up,
                              label: post['likeCount'].toString(),
                              isActive: post['isLiked'],
                              isDynamic: isDynamic,
                              activeColor: Colors.blue,
                              onTap: () {
                                setState(() {
                                  post['isLiked'] = !post['isLiked'];
                                  post['likeCount'] += post['isLiked'] ? 1 : -1;
                                });
                              },
                            ),

                            const SizedBox(width: 24),

                            // 评论数量
                            Row(
                              children: [
                                Icon(
                                  Icons.comment,
                                  size: 20,
                                  color: isDynamic ? Colors.white.withValues(alpha: 0.8) : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  post['commentCount'].toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDynamic ? Colors.white.withValues(alpha: 0.8) : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            // 收藏按钮
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  post['isBookmarked'] = !post['isBookmarked'];
                                });
                              },
                              icon: Icon(
                                post['isBookmarked'] ? Icons.bookmark : Icons.bookmark_border,
                                size: 22,
                                color: post['isBookmarked']
                                    ? (isDynamic ? Colors.amber : Colors.amber[700])
                                    : (isDynamic ? Colors.white.withValues(alpha: 0.8) : Colors.grey[600]),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),

                            const SizedBox(width: 20),

                            // 分享按钮
                            IconButton(
                              onPressed: () {
                                // 分享功能
                              },
                              icon: Icon(
                                Icons.share,
                                size: 20,
                                color: isDynamic ? Colors.white.withValues(alpha: 0.8) : Colors.grey[600],
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),

                        const Divider(height: 40),

                        // 评论标题
                        Text(
                          '评论 (${post['commentCount']})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDynamic ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 评论列表
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final comment = post['comments'][index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 用户头像
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDynamic ? Colors.white.withValues(alpha: 0.3) : Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: _buildImageWidget(
                                  comment['avatar'],
                                  isDynamic: isDynamic,
                                  width: 40,
                                  height: 40
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 评论内容
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 用户名和时间
                                  Row(
                                    children: [
                                      Text(
                                        comment['username'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDynamic ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        comment['createdAt'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDynamic ? Colors.white.withValues(alpha: 0.5) : Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  // 评论内容
                                  Text(
                                    comment['content'],
                                    style: TextStyle(
                                      color: isDynamic ? Colors.white.withValues(alpha: 0.8) : Colors.grey[800],
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // 点赞按钮
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // 点赞功能
                                        },
                                        child: Icon(
                                          Icons.thumb_up_outlined,
                                          size: 16,
                                          color: isDynamic ? Colors.white.withValues(alpha: 0.6) : Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        comment['likeCount'].toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDynamic ? Colors.white.withValues(alpha: 0.6) : Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () {
                                          // 回复功能
                                        },
                                        child: Text(
                                          '回复',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDynamic ? Colors.white.withValues(alpha: 0.6) : Colors.grey[600],
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
                      );
                    },
                    childCount: post['comments'].length,
                  ),
                ),

                // 底部留白
                const SliverToBoxAdapter(
                  child: SizedBox(height: 70),
                ),
              ],
            ),
          ),

          // 底部评论输入框
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDynamic ? Colors.black.withValues(alpha: 0.8) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDynamic ? Colors.grey.withValues(alpha: 0.2) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDynamic ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!,
                        ),
                      ),
                      child: TextField(
                        controller: commentController,
                        style: TextStyle(
                          color: isDynamic ? Colors.white : null,
                        ),
                        decoration: InputDecoration(
                          hintText: '写下你的评论...',
                          hintStyle: TextStyle(
                            color: isDynamic ? Colors.white.withValues(alpha: 0.6) : Colors.grey[500],
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDynamic ? Colors.green : Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // 发送评论
                        if (commentController.text.isNotEmpty) {
                          // 处理评论提交
                          commentController.clear();
                          FocusScope.of(context).unfocus();
                        }
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 发帖对话框
  void _showCreatePostDialog(BuildContext context, bool isDynamic) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedType = '求助';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDynamic ? Colors.black.withValues(alpha: 0.9) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    '发布新帖子',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDynamic ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 帖子类型选择
                  Text(
                    '选择类型',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDynamic ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 类型选择按钮
                  SizedBox(
                    height: 40,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            '求助',
                            '分享',
                            '讨论',
                            '炫耀',
                          ].map((type) {
                            final isSelected = selectedType == type;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedType = type;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDynamic ? _getTypeColor(type).withValues(alpha: 0.3) : _getTypeColor(type).withValues(alpha: 0.1))
                                      : (isDynamic ? Colors.grey.withValues(alpha: 0.2) : Colors.grey[100]),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? _getTypeColor(type).withValues(alpha: isDynamic ? 0.6 : 0.3)
                                        : (isDynamic ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!),
                                  ),
                                ),
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    color: isSelected
                                        ? (isDynamic ? _getTypeColor(type) : _getTypeColor(type))
                                        : (isDynamic ? Colors.white : Colors.grey[700]),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 标题输入
                  TextField(
                    controller: titleController,
                    style: TextStyle(
                      color: isDynamic ? Colors.white : null,
                    ),
                    decoration: InputDecoration(
                      hintText: '输入标题（简明扼要地描述问题）',
                      hintStyle: TextStyle(
                        color: isDynamic ? Colors.white.withValues(alpha: 0.5) : Colors.grey[500],
                      ),
                      filled: true,
                      fillColor: isDynamic ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDynamic ? Colors.white.withValues(alpha: 0.3) : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDynamic ? Colors.white.withValues(alpha: 0.3) : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDynamic ? Colors.green : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 内容输入
                  TextField(
                    controller: contentController,
                    style: TextStyle(
                      color: isDynamic ? Colors.white : null,
                    ),
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: '详细描述你的问题或分享...',
                      hintStyle: TextStyle(
                        color: isDynamic ? Colors.white.withValues(alpha: 0.5) : Colors.grey[500],
                      ),
                      filled: true,
                      fillColor: isDynamic ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDynamic ? Colors.white.withValues(alpha: 0.3) : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDynamic ? Colors.white.withValues(alpha: 0.3) : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDynamic ? Colors.green : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 添加图片按钮
                  OutlinedButton.icon(
                    onPressed: () {
                      // 添加图片功能
                    },
                    icon: Icon(
                      Icons.add_photo_alternate,
                      color: isDynamic ? Colors.green : Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      '添加图片',
                      style: TextStyle(
                        color: isDynamic ? Colors.green : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDynamic ? Colors.green.withValues(alpha: 0.5) : Theme.of(context).colorScheme.primary,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 按钮区域
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 取消按钮
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: isDynamic ? Colors.white70 : null,
                        ),
                        child: const Text('取消'),
                      ),

                      const SizedBox(width: 16),

                      // 发布按钮
                      ElevatedButton(
                        onPressed: () {
                          // 发布帖子
                          if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                            // 处理帖子发布
                            Navigator.pop(context);

                            // 显示成功提示
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('发布成功！'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDynamic ? Colors.green : Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('发布'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
