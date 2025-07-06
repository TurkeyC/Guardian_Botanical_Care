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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                foregroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                textStyle: const TextStyle(
                  inherit: false,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: Icon(icon, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
      // 根据用户选择的API类型进行植物识别
      final plantService = PlantIdentificationService();
      final apiType = settingsProvider.plantIdentificationApiType;

      // 构建API配置
      Map<String, String> apiConfig = {};

      switch (apiType) {
        case 'inaturalist':
          apiConfig = {
            'apiUrl': settingsProvider.inaturalistApiUrl,
            'token': settingsProvider.inaturalistToken,
          };
          break;
        case 'plantid':
          apiConfig = {
            'apiKey': settingsProvider.plantIdApiKey,
          };
          break;
        case 'vlm':
          apiConfig = {
            'apiUrl': settingsProvider.vlmApiUrl,
            'apiKey': settingsProvider.vlmApiKey,
            'model': settingsProvider.vlmModel,
          };
          break;
      }

      // 进行植物识别
      final identificationResult = await plantService.identifyPlant(
        imageFile: imageFile,
        apiType: apiType,
        apiConfig: apiConfig,
      );

      if (identificationResult == null) {
        throw Exception('无法识别植物品种');
      }

      // 如果使用的不是VLM API，需要进行额外的健康分析和养护建议生成
      String healthAnalysis = identificationResult.healthAnalysis;
      String careRecommendations = identificationResult.careRecommendations;

      if (apiType != 'vlm') {
        setState(() {
          _statusMessage = '正在分析植物健康状况...';
        });

        // 使用VLM API进行健康分析
        final openAIService = OpenAIApiService();
        final imageBytes = await imageFile.readAsBytes();
        final imageBase64 = base64Encode(imageBytes);

        final analysisResult = await openAIService.analyzeImage(
          imageBase64: imageBase64,
          apiUrl: settingsProvider.vlmApiUrl,
          apiKey: settingsProvider.vlmApiKey,
          model: settingsProvider.vlmModel,
        );

        if (analysisResult != null) {
          healthAnalysis = analysisResult;
        }

        setState(() {
          _statusMessage = '正在生成养护建议...';
        });

        // 使用LLM API生成养护建议
        final careResult = await openAIService.generateCareAdvice(
          plantSpecies: identificationResult.species,
          healthAnalysis: healthAnalysis,
          apiUrl: settingsProvider.llmApiUrl,
          apiKey: settingsProvider.llmApiKey,
          model: settingsProvider.llmModel,
        );

        if (careResult != null) {
          careRecommendations = careResult;
        }
      }

      // 创建最终的识别结果
      final finalResult = PlantIdentificationResult(
        species: identificationResult.species,
        scientificName: identificationResult.scientificName,
        confidence: identificationResult.confidence,
        healthAnalysis: healthAnalysis,
        careRecommendations: careRecommendations,
        imagePath: imageFile.path,
      );

      // 导航到结果页面
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IdentificationResultScreen(
              result: finalResult,
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
