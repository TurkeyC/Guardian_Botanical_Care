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
import 'package:shimmer/shimmer.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  bool _isPro = false; // 默认非会员

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final proColor = const Color(0xFFFFD700); // 金色

    // 根据会员状态定义颜色
    final screenBackgroundColor = _isPro ? Colors.black : theme.scaffoldBackgroundColor;
    // final cardBackgroundColor = _isPro ? Colors.grey[900] : null;
    final textColor = _isPro ? Colors.white : theme.textTheme.bodyLarge?.color;
    final appBarBackgroundColor = _isPro ? Colors.grey[900] : theme.colorScheme.inversePrimary;

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('会员服务'),
        backgroundColor: appBarBackgroundColor,
        titleTextStyle: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 会员状态卡片
            _buildMembershipStatus(context),
            const SizedBox(height: 24),

            // Pro会员特权
            _buildProFeatures(context),
            const SizedBox(height: 24),

            // 订阅选项
            _buildSubscriptionOptions(context),
            const SizedBox(height: 24),

            // 常见问题
            _buildFAQ(context),

            // 调试开关
            const SizedBox(height: 32),
            _buildDebugSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugSwitch() {
    return Card(
      color: Colors.yellow.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '开发调试选项',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  '预览Pro会员状态',
                  style: TextStyle(color: Colors.black54),
                ),
                Text(
                  '(但是其实我一个会员功能都没做)',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
            Switch(
              value: _isPro,
              onChanged: (value) {
                setState(() {
                  _isPro = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipStatus(BuildContext context) {
    // TODO: 会员判断逻辑: 这里可以根据实际的会员状态来显示不同内容
    // bool isPro = true; // 临时状态，实际应该从数据源获取

    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _isPro ? Icons.workspace_premium : Icons.person_outline,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isPro ? 'Pro会员' : '免费用户',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isPro ? '感谢您的支持！' : '升级Pro享受更多功能',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_isPro) ...[
          // TODO: 具体会员逻辑待开发
          const SizedBox(height: 16),
          const Text(
            '到期时间: 2024年12月31日',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _isPro
              ? const LinearGradient(
                  colors: [Color(0xFF2C2C2C), Color(0xFF1B1B1B)], // 深色背景
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF6C7CE7), Color(0xFF4FACFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: _isPro
            ? Shimmer.fromColors(
                baseColor: const Color(0xFFFFD700),
                highlightColor: const Color(0xFFFFFDE4),
                child: cardContent,
              )
            : cardContent,
      ),
    );
  }

  Widget _buildProFeatures(BuildContext context) {
    final theme = Theme.of(context);
    final proColor = const Color(0xFFFFD700); // 金色

    // 根据会员状态定义颜色
    final cardBackgroundColor = _isPro ? Colors.grey[900] : null;
    final textColor = _isPro ? Colors.white : theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = _isPro ? Colors.white70 : theme.textTheme.bodyMedium?.color;
    final primaryColor = _isPro ? proColor : theme.colorScheme.primary;

    final features = [
      {
        'icon': Icons.auto_awesome,
        'title': '无限识别次数',
        'subtitle': '不再受每日识别次数限制',
      },
      {
        'icon': Icons.speed,
        'title': '优先识别速度',
        'subtitle': '享受更快的识别响应时间',
      },
      {
        'icon': Icons.high_quality,
        'title': '高精度识别',
        'subtitle': '使用高级AI模型，识别准确率更高',
      },
      {
        'icon': Icons.groups_rounded, // Icons.assignment_ind_rounded
        'title': '专家咨询',
        'subtitle': '享受园艺专家一对一指导服务',
      },
      {
        'icon': Icons.computer_rounded,
        'title': 'AI深度诊断',
        'subtitle': '自研AI大模型，精准的植物健康诊断',
      },
      {
        'icon': Icons.cloud_sync,
        'title': '云端同步',
        'subtitle': '数据云端备份，多设备同步',
      },
      {
        'icon': Icons.update,
        'title': '抢先体验(终身会员专属)',
        'subtitle': '优先体验新功能和特性',
      },
    ];

    return Card(
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pro会员特权',
                  style: theme.textTheme.titleLarge?.copyWith(color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(color: textColor),
                        ),
                        Text(
                          feature['subtitle'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOptions(BuildContext context) {
    final theme = Theme.of(context);
    final proColor = const Color(0xFFFFD700); // 金色

    // 根据会员状态定义颜色
    final cardBackgroundColor = _isPro ? Colors.grey[900] : null;
    final textColor = _isPro ? Colors.white : theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = _isPro ? Colors.white70 : theme.textTheme.bodyMedium?.color;
    final primaryColor = _isPro ? proColor : theme.colorScheme.primary;

    final plans = [
      {
        'title': '月度会员',
        'price': '¥6', //原定价 19
        'period': '/月',
        'originalPrice': '¥19', //原定价 29
        'discount': '新品限时特惠, 截至2025年9月7日',
        'features': ['多数Pro功能', '月度账单', '随时取消'],
      },
      {
        'title': '年度会员',
        'price': '¥128', //原定价 128
        'period': '/年',
        'originalPrice': '¥228', //原定价 228
        'discount': '限时优惠, 省¥100',
        'features': ['多数Pro功能', '年度账单', '最优惠价格'],
        'isRecommended': true,
      },
      {
        'title': '终身会员',
        'price': '¥328', //原定价 298
        'period': '/买断',
        'originalPrice': '¥648', //原定价 498
        'discount': '限时优惠, 省¥320',
        'features': ['所有Pro功能(含抢先体验功能)', '一次付费', '终身使用'],
      },
    ];

    return Card(
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '会员订阅选项',
                  style: theme.textTheme.titleLarge?.copyWith(color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...plans.map((plan) {
              final isRecommended = plan['isRecommended'] == true;

              Widget planCard = Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isRecommended
                      ? primaryColor
                      : Colors.grey.withOpacity(0.3),
                    width: isRecommended ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isRecommended
                    ? primaryColor.withOpacity(0.05)
                    : cardBackgroundColor,
                ),
                child: Stack(
                  children: [
                    if (isRecommended)
                      Positioned.fill(
                        child: Shimmer.fromColors(
                          baseColor: primaryColor.withOpacity(0.05),
                          highlightColor: primaryColor.withOpacity(0.2),
                          period: const Duration(seconds: 3),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white, // Shimmer needs a color to draw on
                            ),
                          ),
                        ),
                      ),
                    if (isRecommended)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            '推荐',
                            style: TextStyle(
                              color: _isPro ? Colors.black : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                plan['title'] as String,
                                style: theme.textTheme.titleMedium?.copyWith(color: textColor),
                              ),
                              const Spacer(),
                              if (plan['originalPrice'] != null) ...[
                                Text(
                                  plan['originalPrice'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                plan['price'] as String,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                plan['period'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                              ),
                            ],
                          ),
                          if (plan['discount'] != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                plan['discount'] as String,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          ...(plan['features'] as List<String>).map(
                            (feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    feature,
                                    style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _showSubscriptionDialog(context, plan['title'] as String);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isRecommended
                                  ? primaryColor
                                  : (_isPro ? Colors.grey.shade800 : null),
                                foregroundColor: _isPro
                                  ? (isRecommended ? Colors.black : Colors.white)
                                  : (isRecommended ? Colors.white : null),
                              ),
                              child: Text('选择 ${plan['title']}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              return planCard;
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQ(BuildContext context) {
    final theme = Theme.of(context);
    final proColor = const Color(0xFFFFD700); // 金色

    // 根据会员状态定义颜色
    final cardBackgroundColor = _isPro ? Colors.grey[900] : null;
    final textColor = _isPro ? Colors.white : theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = _isPro ? Colors.white70 : theme.textTheme.bodyMedium?.color;
    final primaryColor = _isPro ? proColor : theme.colorScheme.primary;

    final faqs = [
      {
        'question': '如何取消订阅？',
        'answer': '您可以随时在设置中取消订阅，取消后仍可使用到当前计费周期结束。',
      },
      {
        'question': '会员功能什么时候生效？',
        'answer': '支付成功后会员功能立即生效，您可以立即享受所有Pro特权。',
      },
      {
        'question': '支持哪些支付方式？',
        'answer': '暂时仅支持二维码支付，后续将会支持微信支付、支付宝、银行卡等多种支付方式。',
      },
      {
        'question': '数据安全有保障吗？',
        'answer': '我们采用AI生成的数据加密技术，确保您的数据安全。',
      },
      {
        'question': 'Ciallo～(∠・ω< )⌒☆',
        'answer': '柚子厨蒸鹅心! Ciallo～(∠・ω< )⌒☆',
      },
    ];

    return Card(
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '常见问题',
                  style: theme.textTheme.titleLarge?.copyWith(color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...faqs.map((faq) => ExpansionTile(
              iconColor: primaryColor,
              collapsedIconColor: primaryColor,
              title: Text(
                faq['question'] as String,
                style: theme.textTheme.titleMedium?.copyWith(color: textColor),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    faq['answer'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                  ),
                ),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context, String planName) {
    final theme = Theme.of(context);
    final proColor = const Color(0xFFFFD700);
    final isPro = _isPro;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isPro ? Colors.grey[900] : null,
        titleTextStyle: TextStyle(
          color: isPro ? proColor : theme.textTheme.titleLarge?.color,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        contentTextStyle: TextStyle(
          color: isPro ? Colors.white : theme.textTheme.bodyLarge?.color,
        ),
        title: const Text('确认订阅'),
        content: Text('您确定要订阅$planName吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(
                color: isPro ? Colors.white70 : null,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPaymentQRCode(context, planName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isPro ? proColor : theme.colorScheme.primary,
              foregroundColor: isPro ? Colors.black : Colors.white,
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showPaymentQRCode(BuildContext context, String planName) {
    final theme = Theme.of(context);
    final proColor = const Color(0xFFFFD700);
    final isPro = _isPro;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isPro ? Colors.grey[900] : null,
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          '请扫码支付',
          style: TextStyle(
            color: isPro ? proColor : theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '订阅: $planName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPro ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: isPro ? Border.all(color: proColor, width: 2) : null,
                boxShadow: isPro ? [
                  BoxShadow(
                    color: proColor.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ] : null,
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/GBC_Pay_trans.png',
                width: 230,
                height: 230,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '请扫描上方二维码完成支付',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isPro ? Colors.white70 : null,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消支付',
              style: TextStyle(
                color: isPro ? Colors.white70 : null,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(context, planName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isPro ? proColor : theme.colorScheme.primary,
              foregroundColor: isPro ? Colors.black : Colors.white,
            ),
            child: const Text('我已支付'),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context, String planName) {
    // TODO: 这里可以集成实际的支付验证逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在验证支付状态，请稍后...'),
        duration: Duration(seconds: 2),
      ),
    );

    // 模拟支付处理
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('订阅成功！感谢您的支持'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isPro = true;
        });
      }
    });
  }
}
