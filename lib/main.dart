import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/my_plants_screen.dart';
import 'screens/care_reminder_screen.dart';
import 'screens/photo_identify_screen.dart';
import 'screens/diagnosis_screen.dart';
import 'screens/settings_screen.dart';
import 'services/api_service.dart';
import 'providers/plant_provider.dart';
import 'providers/settings_provider.dart';
import 'themes/app_themes.dart';
import 'widgets/apple_style_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化API服务
  ApiService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlantProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // 在应用启动时加载设置
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!settingsProvider.isLoading) {
            settingsProvider.loadSettings();
          }
        });

        return MaterialApp(
          title: 'Guardian Botanical Care',
          theme: AppThemes.getTheme(settingsProvider.currentTheme),
          home: const MainScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MyPlantsScreen(),
    const CareReminderScreen(),
    const PhotoIdentifyScreen(),
    const DiagnosisScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDynamicTheme = settingsProvider.currentTheme == AppThemeType.dynamic;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: isDynamicTheme
          ? GlassBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.eco_rounded),
                  label: '我的植物',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_rounded),
                  label: '养护提醒',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt_rounded),
                  label: '拍照识别',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.medical_services_rounded),
                  label: '专业诊断',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: '应用设置',
                ),
              ],
            )
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.eco),
                  label: '我的植物',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: '养护提醒',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt),
                  label: '拍照识别',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.medical_services),
                  label: '专业诊断',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: '应用设置',
                ),
              ],
            ),
    );
  }
}
