import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/apple_style_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 设置定时器，3秒后跳转到主界面
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: Container(
       width: double.infinity,
       height: double.infinity,
       decoration: const BoxDecoration(
         image: DecorationImage(
            image: AssetImage('assets/images/gbc_OP.png'),
            fit: BoxFit.cover, // 确保图片铺满整个屏幕
         ),
       ),
     ),
   );
  }
}