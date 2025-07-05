import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/plant_provider.dart';
import '../providers/settings_provider.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('养护提醒'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadWeatherInfo,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<PlantProvider>(
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
      ),
    );
  }

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
              _buildWeatherContent()
            else
              const Text('暂无天气信息'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
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
                value: '${weather.current.humidity}%',
              ),
              _buildWeatherDetail(
                icon: Icons.air,
                label: '风速',
                value: '${weather.current.windKph.round()} km/h',
              ),
              _buildWeatherDetail(
                icon: Icons.wb_sunny_outlined,
                label: 'UV指数',
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
              Text('浇水提醒: ${plant.wateringFrequency}'),
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
