import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import '../models/plant.dart';
import 'identification_result_screen.dart';

class PhotoIdentifyScreen extends StatefulWidget {
  const PhotoIdentifyScreen({super.key});

  @override
  State<PhotoIdentifyScreen> createState() => _PhotoIdentifyScreenState();
}

class _PhotoIdentifyScreenState extends State<PhotoIdentifyScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('拍照识别'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 120,
                color: Colors.green[300],
              ),
              const SizedBox(height: 32),
              const Text(
                '拍摄或选择植物照片',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '我们将通过AI识别植物品种\n分析健康状况并提供养护建议',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              if (_isProcessing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.camera_alt,
                      label: '拍照',
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    _buildActionButton(
                      icon: Icons.photo_library,
                      label: '相册',
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: const CircleBorder(),
            backgroundColor: Colors.green[100],
            foregroundColor: Colors.green[700],
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        await _processImage(imageFile);
      }
    } catch (e) {
      _showErrorDialog('选择图片失败: $e');
    }
  }

  Future<void> _processImage(File imageFile) async {
    final settingsProvider = context.read<SettingsProvider>();

    // 检查设置完整性
    if (!await settingsProvider.areSettingsComplete()) {
      _showSettingsIncompleteDialog();
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = '正在识别植物品种...';
    });

    try {
      // 步骤1: 调用iNaturalist API识别植物
      final iNaturalistService = INaturalistApiService();
      final identificationResult = await iNaturalistService.identifyPlant(
        imageFile: imageFile,
        apiUrl: settingsProvider.inaturalistApiUrl,
        token: settingsProvider.inaturalistToken,
      );

      if (identificationResult == null || identificationResult.results.isEmpty) {
        throw Exception('无法识别植物品种');
      }

      setState(() {
        _statusMessage = '正在分析植物健康状况...';
      });

      // 步骤2: 调用OpenAI视觉模型分析健康状况
      final openAIService = OpenAIApiService();
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      final healthAnalysis = await openAIService.analyzeImage(
        imageBase64: imageBase64,
        apiUrl: settingsProvider.openaiApiUrl,
        apiKey: settingsProvider.openaiApiKey,
        model: settingsProvider.visionModel,
      );

      if (healthAnalysis == null) {
        throw Exception('健康状况分析失败');
      }

      setState(() {
        _statusMessage = '正在生成养护建议...';
      });

      // 步骤3: 生成养护建议
      final bestResult = identificationResult.results.first;
      final plantName = bestResult.taxon.preferredCommonName ?? bestResult.taxon.name;

      final careAdvice = await openAIService.generateCareAdvice(
        plantSpecies: plantName,
        healthAnalysis: healthAnalysis,
        apiUrl: settingsProvider.openaiApiUrl,
        apiKey: settingsProvider.openaiApiKey,
        model: settingsProvider.textModel,
      );

      if (careAdvice == null) {
        throw Exception('养护建议生成失败');
      }

      // 创建识别结果
      final result = PlantIdentificationResult(
        species: plantName,
        scientificName: bestResult.taxon.name,
        confidence: bestResult.score,
        healthAnalysis: healthAnalysis,
        careRecommendations: careAdvice,
        imagePath: imageFile.path,
      );

      // 导航到结果页面
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IdentificationResultScreen(
              result: result,
              imageFile: imageFile,
            ),
          ),
        );
      }

    } catch (e) {
      _showErrorDialog('识别过程中出现错误: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = '';
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSettingsIncompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置未完成'),
        content: const Text('请先在"应用设置"中配置API密钥和地址。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
