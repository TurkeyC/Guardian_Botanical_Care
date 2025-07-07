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
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_provider.dart';
import '../providers/settings_provider.dart';
import '../themes/app_themes.dart';
import '../widgets/apple_style_widgets.dart';
import '../widgets/apple_animations.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../models/plant.dart';

class CareReminderScreen extends StatefulWidget {
  const CareReminderScreen({super.key});

  @override
  State<CareReminderScreen> createState() => _CareReminderScreenState();
}

class _CareReminderScreenState extends State<CareReminderScreen> {
  WeatherInfo? _weatherInfo;
  bool _isLoadingWeather = false;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    _loadWeatherInfo();
  }

  Future<void> _loadWeatherInfo() async {
    final settingsProvider = context.read<SettingsProvider>();
    final weatherApiKey = settingsProvider.weatherApiKey;

    if (weatherApiKey.isEmpty) {
      setState(() {
        _weatherError = '请先在设置中配置Weather API密钥';
      });
      return;
    }

    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    try {
      // 获取位置信息
      final locationService = LocationService();
      final hasPermission = await locationService.hasLocationPermission();

      if (!hasPermission) {
        final granted = await locationService.requestLocationPermission();
        if (!granted) {
          setState(() {
            _weatherError = '需要位置权限才能获取天气信息';
            _isLoadingWeather = false;
          });
          return;
        }
      }

      final position = await locationService.getCurrentLocation();
      if (position == null) {
        setState(() {
          _weatherError = '无法获取当前位置';
          _isLoadingWeather = false;
        });
        return;
      }

      // 获取天气信息
      final weatherService = WeatherService();
      final weatherInfo = await weatherService.getWeatherInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        apiKey: weatherApiKey,
        apiUrl: settingsProvider.weatherApiUrl,
      );

      setState(() {
        _weatherInfo = weatherInfo;
        _isLoadingWeather = false;
      });
    } catch (e) {
      setState(() {
        _weatherError = '获取天气信息失败: $e';
        _isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDynamicTheme = settingsProvider.currentTheme == AppThemeType.dynamic;

    return Scaffold(
      appBar: isDynamicTheme
          ? const GlassAppBar(title: '养护提醒')
          : AppBar(
              title: const Text('养护提醒'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                IconButton(
                  onPressed: _loadWeatherInfo,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
      body: isDynamicTheme
          ? ParticleBackground(child: _buildDynamicBody())
          : _buildMinimalBody(),
    );
  }

  Widget _buildDynamicBody() {
    return Consumer<PlantProvider>(
      builder: (context, plantProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await _loadWeatherInfo();
            await plantProvider.loadPlants();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 天气信息卡片 - 苹果风格
              AnimatedContainer2D(
                animationType: AnimationType.slideUp,
                duration: const Duration(milliseconds: 800),
                child: _buildDynamicWeatherCard(),
              ),
              const SizedBox(height: 24),

              // 植物养护提醒列表
              if (plantProvider.plants.isEmpty)
                _buildDynamicEmptyState()
              else
                ..._buildDynamicPlantReminders(plantProvider.plants),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMinimalBody() {
    return Consumer<PlantProvider>(
      builder: (context, plantProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await _loadWeatherInfo();
            await plantProvider.loadPlants();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 天气信息卡片
              _buildWeatherCard(),
              const SizedBox(height: 16),

              // 植物养护提醒列表
              if (plantProvider.plants.isEmpty)
                _buildEmptyState()
              else
                ..._buildPlantReminders(plantProvider.plants),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDynamicWeatherCard() {
    return GradientCard(
      gradientColors: AppThemes.appleBlueGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                '今日天气',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoadingWeather)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else if (_weatherError != null)
            GlassContainer(
              backgroundColor: Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _weatherError!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          else if (_weatherInfo != null)
            _buildDynamicWeatherContent()
          else
            const Text(
              '暂无天气信息',
              style: TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  Widget _buildDynamicWeatherContent() {
    final weather = _weatherInfo!;

    return Column(
      children: [
        Row(
          children: [
            // 温度和天气状况
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.current.tempC.round()}°C',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    weather.current.condition.text,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '体感 ${weather.current.feelslikeC.round()}°C',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // 天气图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getWeatherIcon(weather.current.condition.text),
                size: 40,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 详细信息 - 毛玻璃卡片
        GlassContainer(
          backgroundColor: Colors.white.withOpacity(0.15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDynamicWeatherDetail(
                icon: Icons.opacity_rounded,
                label: '湿度',
                value: '${weather.current.humidity}',
              ),
              _buildDynamicWeatherDetail(
                icon: Icons.air_rounded,
                label: '风速',
                value: '${weather.current.windKph.round()}',
              ),
              _buildDynamicWeatherDetail(
                icon: Icons.wb_sunny_outlined,
                label: 'UV',
                value: weather.current.uv.round().toString(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildDynamicWeatherAdvice(weather),
      ],
    );
  }

  Widget _buildDynamicWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.white),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicWeatherAdvice(WeatherInfo weather) {
    String advice = '';
    List<Color> adviceColors = AppThemes.appleGreenGradient;
    IconData adviceIcon = Icons.check_circle_outline_rounded;

    if (weather.current.tempC > 30) {
      advice = '高温天气，注意遮阴增湿';
      adviceColors = [const Color(0xFFFF3B30), const Color(0xFFFF6B35)];
      adviceIcon = Icons.warning_amber_rounded;
    } else if (weather.current.tempC < 10) {
      advice = '低温天气，注意保温';
      adviceColors = AppThemes.appleBlueGradient;
      adviceIcon = Icons.ac_unit_rounded;
    } else if (weather.current.humidity < 30) {
      advice = '空气干燥，增加湿度';
      adviceColors = AppThemes.appleOrangeGradient;
      adviceIcon = Icons.opacity_rounded;
    } else {
      advice = '天气条件良好';
      adviceColors = AppThemes.appleGreenGradient;
      adviceIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: adviceColors),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: adviceColors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(adviceIcon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              advice,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicEmptyState() {
    return AnimatedContainer2D(
      animationType: AnimationType.combined,
      child: GlassContainer(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppThemes.applePurpleGradient,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '暂无养护提醒',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '添加植物后，这里将会显示个性化的养护建议',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicPlantReminders(List<Plant> plants) {
    return plants.asMap().entries.map((entry) {
      final index = entry.key;
      final plant = entry.value;

      return AnimatedContainer2D(
        animationType: AnimationType.slideUp,
        duration: Duration(milliseconds: 1000 + (index * 100)),
        child: FloatingCard(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              // 植物图片
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: AppThemes.appleGreenGradient,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: plant.imagePath.isNotEmpty
                      ? Image.file(
                          File(plant.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.eco_rounded, color: Colors.white),
                        )
                      : const Icon(Icons.eco_rounded, color: Colors.white),
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
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '健康状态: ${plant.healthStatus}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    if (plant.wateringFrequency.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '浇水提醒: ${_parseSimpleText(plant.wateringFrequency)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFAEAEB2),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 提醒按钮
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppThemes.appleOrangeGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: 设置提醒逻辑
                  },
                  icon: const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// 简单文本解析，支持解析带有换行的文本和JSON格式
  String _parseSimpleText(String content) {
    try {
      // 尝试解析JSON，提取具体的值
      final jsonData = jsonDecode(content);
      if (jsonData is Map<String, dynamic>) {
        // 如果是JSON对象，尝试提取有用的信息
        if (jsonData.containsKey('watering')) {
          return jsonData['watering'].toString();
        } else if (jsonData.containsKey('lighting')) {
          return jsonData['lighting'].toString();
        } else if (jsonData.containsKey('fertilization')) {
          return jsonData['fertilization'].toString();
        } else {
          // 如果找不到特定字段，返回第一个值
          return jsonData.values.first.toString();
        }
      }
    } catch (e) {
      // JSON解析失败，按照普通文本处理
    }

    // 普通文本处理：替换换行符为逗号并去除多余的空格
    return content.replaceAll('\n', ', ').replaceAll(RegExp(r',\s*'), ', ').trim();
  }

  // 简约主题的原始方法
  Widget _buildWeatherCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  '当前天气',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isLoadingWeather)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_weatherError != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _weatherError!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              )
            else if (_weatherInfo != null)
              _buildWeatherInfo(_weatherInfo!),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(WeatherInfo weather) {
    return Column(
      children: [
        Row(
          children: [
            // 温度和天气状况
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.current.tempC.round()}°C',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    weather.current.condition.text,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '体感温度 ${weather.current.feelslikeC.round()}°C',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // 天气图标和位置
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getWeatherIcon(weather.current.condition.text),
                      size: 32,
                      color: Colors.blue[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weather.location.name,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 详细信息
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(
                icon: Icons.opacity,
                label: '湿度',
                value: '${weather.current.humidity}',
              ),
              _buildWeatherDetail(
                icon: Icons.air,
                label: '风速',
                value: '${weather.current.windKph.round()}',
              ),
              _buildWeatherDetail(
                icon: Icons.wb_sunny_outlined,
                label: 'UV',
                value: weather.current.uv.round().toString(),
              ),
            ],
          ),
        ),

        // 养护建议
        const SizedBox(height: 12),
        _buildWeatherAdvice(weather),
      ],
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherAdvice(WeatherInfo weather) {
    String advice = '';
    Color adviceColor = Colors.blue;
    IconData adviceIcon = Icons.info_outline;

    if (weather.current.tempC > 30) {
      advice = '高温天气，注意给植物遮阴和增加浇水频率';
      adviceColor = Colors.red;
      adviceIcon = Icons.warning_amber;
    } else if (weather.current.tempC < 10) {
      advice = '低温天气，注意植物保温，减少浇水';
      adviceColor = Colors.blue;
      adviceIcon = Icons.ac_unit;
    } else if (weather.current.humidity < 30) {
      advice = '空气干燥，可考虑增加环境湿度';
      adviceColor = Colors.orange;
      adviceIcon = Icons.opacity;
    } else if (weather.current.humidity > 80) {
      advice = '湿度较高，注意通风，避免真菌感染';
      adviceColor = Colors.teal;
      adviceIcon = Icons.air;
    } else {
      advice = '天气条件良好，适合植物生长';
      adviceColor = Colors.green;
      adviceIcon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: adviceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: adviceColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(adviceIcon, color: adviceColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              advice,
              style: TextStyle(
                color: adviceColor.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('sun') || lowerCondition.contains('clear')) {
      return Icons.wb_sunny;
    } else if (lowerCondition.contains('cloud')) {
      return Icons.wb_cloudy;
    } else if (lowerCondition.contains('rain')) {
      return Icons.grain;
    } else if (lowerCondition.contains('snow')) {
      return Icons.ac_unit;
    } else if (lowerCondition.contains('storm') || lowerCondition.contains('thunder')) {
      return Icons.flash_on;
    } else {
      return Icons.wb_cloudy;
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
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
      ),
    );
  }

  List<Widget> _buildPlantReminders(List<Plant> plants) {
    return plants.map((plant) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: plant.imagePath.isNotEmpty
              ? FileImage(File(plant.imagePath))
              : null,
          child: plant.imagePath.isEmpty
              ? const Icon(Icons.local_florist)
              : null,
        ),
        title: Text(plant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('健康状态: ${plant.healthStatus}'),
            if (plant.wateringFrequency.isNotEmpty)
              Text('浇水提醒: ${_parseSimpleText(plant.wateringFrequency)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.notifications_active),
          onPressed: () {
            // TODO: 设置提醒逻辑
          },
        ),
      ),
    )).toList();
  }
}
