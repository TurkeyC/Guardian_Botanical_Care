import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 获取当前位置
  Future<Position?> getCurrentLocation() async {
    try {
      // 检查位置服务是否启用
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('位置服务未启用');
        return null;
      }

      // 检查权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('位置权限被拒绝');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('位置权限被永久拒绝');
        return null;
      }

      // 获取当前位置
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // 降低精度要求
        timeLimit: const Duration(seconds: 10), // 添加超时限制
      );

      return position;
    } catch (e) {
      print('获取位置失败: $e');
      return null;
    }
  }

  /// 检查是否有位置权限
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// 请求位置权限
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      print('请求位置权限失败: $e');
      return false;
    }
  }

  /// 打开应用设置
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
