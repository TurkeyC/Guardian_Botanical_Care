import 'dart:async';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class ApiConnectionTester {
  /// 测试API连接可用性
  static Future<ApiTestResult> testVLMConnection({
    required String apiUrl, // 现在期望完整的API地址
    required String apiKey,
    String model = 'gpt-4-vision-preview',
  }) async {
    try {
      print('开始测试VLM API连接: $apiUrl');

      // 使用简单的文本请求测试连接
      final testRequest = {
        'model': model.contains('vision') ? 'gpt-4' : model,
        'messages': [
          {
            'role': 'user',
            'content': '请回复"连接测试成功"'
          }
        ],
        'max_tokens': 10
      };

      final apiService = ApiService.instance;

      // 直接使用用户提供的完整API地址，不再添加路径
      print('实际请求URL: $apiUrl');

      final response = await apiService.dio.post(
        apiUrl,
        data: testRequest,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          extra: {'retryCount': 0},
        ),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        print('API连接测试成功');
        return ApiTestResult(
          success: true,
          message: 'API连接正常',
          latency: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        print('API连接测试失败: HTTP ${response.statusCode}');
        return ApiTestResult(
          success: false,
          message: 'API返回错误: HTTP ${response.statusCode}',
          errorCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      print('API连接测试异常: $e');

      String errorMessage = '连接失败';
      String? errorCode;

      if (e.toString().contains('SocketException')) {
        if (e.toString().contains('Failed host lookup')) {
          errorMessage = 'DNS解析失败，请检查API地址是否正确';
          errorCode = 'DNS_ERROR';
        } else if (e.toString().contains('Connection refused')) {
          errorMessage = '连接被拒绝，服务可能不可用';
          errorCode = 'CONNECTION_REFUSED';
        } else if (e.toString().contains('Broken pipe')) {
          errorMessage = '连接中断，请检查网络稳定性';
          errorCode = 'BROKEN_PIPE';
        } else {
          errorMessage = '网络连接错误';
          errorCode = 'NETWORK_ERROR';
        }
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = '连接超时，请检查网络或稍后重试';
        errorCode = 'TIMEOUT';
      } else if (e.toString().contains('401')) {
        errorMessage = 'API密钥无效';
        errorCode = 'INVALID_API_KEY';
      } else if (e.toString().contains('403')) {
        errorMessage = 'API访问被禁止';
        errorCode = 'FORBIDDEN';
      } else if (e.toString().contains('429')) {
        errorMessage = 'API调用频率超限';
        errorCode = 'RATE_LIMIT';
      }

      return ApiTestResult(
        success: false,
        message: errorMessage,
        errorCode: errorCode,
        rawError: e.toString(),
      );
    }
  }

  /// 测试位置服务
  static Future<LocationTestResult> testLocationService() async {
    try {
      final locationService = LocationService();
      final hasPermission = await locationService.hasLocationPermission();

      if (!hasPermission) {
        return LocationTestResult(
          success: false,
          message: '位置权限未授予',
          hasPermission: false,
        );
      }

      final position = await locationService.getCurrentLocation();

      if (position != null) {
        return LocationTestResult(
          success: true,
          message: '位置获取成功',
          hasPermission: true,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } else {
        return LocationTestResult(
          success: false,
          message: '无法获取位置信息',
          hasPermission: true,
        );
      }
    } catch (e) {
      return LocationTestResult(
        success: false,
        message: '位置服务测试失败: $e',
        hasPermission: false,
      );
    }
  }
}

class ApiTestResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? rawError;
  final int? latency;

  ApiTestResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.rawError,
    this.latency,
  });
}

class LocationTestResult {
  final bool success;
  final String message;
  final bool hasPermission;
  final double? latitude;
  final double? longitude;

  LocationTestResult({
    required this.success,
    required this.message,
    required this.hasPermission,
    this.latitude,
    this.longitude,
  });
}
