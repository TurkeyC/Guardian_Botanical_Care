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
import 'screens/my_plants_screen.dart';
import 'screens/care_reminder_screen.dart';
import 'screens/photo_identify_screen.dart';
import 'screens/diagnosis_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/membership_screen.dart'; // 添加会员页面导入
import 'services/api_service.dart';
import 'providers/plant_provider.dart';
import 'providers/settings_provider.dart';
import 'themes/app_themes.dart';
import 'widgets/apple_style_widgets.dart';
import 'screens/splash_screen.dart'; // 添加启动页导入
import 'package:window_manager/window_manager.dart';// 添加Windows窗口管理器导入
import 'dart:io'; // 添加 Platform 类的导入
import 'package:flutter_localizations/flutter_localizations.dart'; // 添加本地化支持导入
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // 添加 SQLite FFI 支持导入

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Windows 平台窗口设置
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(400, 800),  // 初始窗口大小，类似手机尺寸
      minimumSize: Size(360, 640),  // 最小窗口大小
      maximumSize: Size(480, 900),  // 最大窗口大小，防止窗口过宽
      center: true,  // 窗口居中显示
      backgroundColor: Colors.transparent,
      title: 'Guardian Botanical Care',
      titleBarStyle: TitleBarStyle.normal,
    );

    // 设置窗口图标
    await windowManager.setIcon('assets/images/windows_icon.png');


    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // 初始化 SQLite FFI
    sqfliteFfiInit();
    // 设置数据库工厂
    databaseFactory = databaseFactoryFfi;

  }

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

        // 获取基础主题
        final baseTheme = AppThemes.getTheme(settingsProvider.currentTheme);

        // 根据平台选择适当的字体
        final platformSpecificTheme = Platform.isWindows
            ? baseTheme.copyWith(
          textTheme: baseTheme.textTheme.apply(
            fontFamily: 'Microsoft YaHei',
          ),
        )
            : baseTheme;

        return MaterialApp(
          title: 'Guardian Botanical Care',
          theme: platformSpecificTheme,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('en', 'US'),
          ],
          // 确保在桌面平台上使用"竖向"的布局
          builder: (context, child) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: child!,
              ),
            );
          },
          // 添加路由配置
          routes: {
            '/home': (context) => const MainScreen(),
            '/membership': (context) => const MembershipScreen(),
          },
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
