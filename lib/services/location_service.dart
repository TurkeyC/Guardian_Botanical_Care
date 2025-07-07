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

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// 获取当前位置
  Future<Position?> getCurrentLocation() async {
    try {
      // 首先使用permission_handler检查和请求权限
      await _requestLocationPermissions();

      // 检查位置服务是否启用
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('位置服务未启用，请在设置中开启位置服务');
      }

      // 再次检查geolocator权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('位置权限被拒绝，无法获取天气信息');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('位置权限被永久拒绝，请在设置中手动开启位置权限');
      }

      // 获取当前位置
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 15),
      );

      return position;
    } catch (e) {
      print('获取位置失败: $e');
      rethrow;
    }
  }

  /// 使用permission_handler请求位置权限
  Future<void> _requestLocationPermissions() async {
    // 检查精确位置权限
    var status = await Permission.location.status;

    if (status.isDenied) {
      // 请求权限
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      throw Exception('位置权限被永久拒绝，请在应用设置中手动开启');
    }

    if (status.isDenied) {
      throw Exception('需要位置权限才能获取天气信息');
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
