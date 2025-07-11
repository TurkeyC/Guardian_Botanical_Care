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
import '../providers/settings_provider.dart';

class ServiceSettingsScreen extends StatefulWidget {
  const ServiceSettingsScreen({super.key});

  @override
  State<ServiceSettingsScreen> createState() => _ServiceSettingsScreenState();
}

class _ServiceSettingsScreenState extends State<ServiceSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // 控制器
  final _inaturalistUrlController = TextEditingController();
  final _inaturalistTokenController = TextEditingController();
  final _llmApiUrlController = TextEditingController();
  final _llmApiKeyController = TextEditingController();
  final _llmModelController = TextEditingController();
  final _vlmApiUrlController = TextEditingController();
  final _vlmApiKeyController = TextEditingController();
  final _vlmModelController = TextEditingController();
  final _plantIdApiKeyController = TextEditingController();
  final _weatherApiKeyController = TextEditingController();
  final _weatherApiUrlController = TextEditingController();

  String _selectedPlantApiType = 'inaturalist';

  // 添加测试状态跟踪
  bool _isTestingLLM = false;
  bool _isTestingVLM = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  void _loadSettings() async {
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.loadSettings();

    setState(() {
      _selectedPlantApiType = settingsProvider.plantIdentificationApiType;
      _inaturalistUrlController.text = settingsProvider.inaturalistApiUrl;
      _inaturalistTokenController.text = settingsProvider.inaturalistToken;
      _llmApiUrlController.text = settingsProvider.llmApiUrl;
      _llmApiKeyController.text = settingsProvider.llmApiKey;
      _llmModelController.text = settingsProvider.llmModel;
      _vlmApiUrlController.text = settingsProvider.vlmApiUrl;
      _vlmApiKeyController.text = settingsProvider.vlmApiKey;
      _vlmModelController.text = settingsProvider.vlmModel;
      _plantIdApiKeyController.text = settingsProvider.plantIdApiKey;
      _weatherApiKeyController.text = settingsProvider.weatherApiKey;
      _weatherApiUrlController.text = settingsProvider.weatherApiUrl;
    });
  }

  @override
  void dispose() {
    _inaturalistUrlController.dispose();
    _inaturalistTokenController.dispose();
    _llmApiUrlController.dispose();
    _llmApiKeyController.dispose();
    _llmModelController.dispose();
    _vlmApiUrlController.dispose();
    _vlmApiKeyController.dispose();
    _vlmModelController.dispose();
    _plantIdApiKeyController.dispose();
    _weatherApiKeyController.dispose();
    _weatherApiUrlController.dispose();
    super.dispose();
  }

  // TODO: 需要修复难以复制粘贴的问题

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务配置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 植物识别API选择
                _buildPlantIdentificationSection(),
                const SizedBox(height: 24),

                // LLM API设置
                _buildLLMApiSection(),
                const SizedBox(height: 24),

                // VLM API设置
                _buildVLMApiSection(),
                const SizedBox(height: 24),

                // Weather API设置
                _buildWeatherApiSection(),

                if (settingsProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        settingsProvider.error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlantIdentificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_florist,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '植物识别设置',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // API类型选择
            Text('识别API类型', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPlantApiType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '选择植物识别API',
              ),
              items: const [
                DropdownMenuItem(value: 'inaturalist', child: Text('iNaturalist')),
                DropdownMenuItem(value: 'plantid', child: Text('Plant.id')),
                DropdownMenuItem(value: 'vlm', child: Text('VLM (视觉语言模型)')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPlantApiType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 根据选择的API类型显示相应配置
            if (_selectedPlantApiType == 'inaturalist') ..._buildINaturalistSettings(),
            if (_selectedPlantApiType == 'plantid') ..._buildPlantIdSettings(),
            if (_selectedPlantApiType == 'vlm')
              Text('使用下方配置的VLM API进行植物识别',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildINaturalistSettings() {
    return [
      TextFormField(
        controller: _inaturalistUrlController,
        decoration: const InputDecoration(
          labelText: 'iNaturalist API URL',
          border: OutlineInputBorder(),
          hintText: 'https://api.inaturalist.org',
        ),
        validator: (value) => value?.isEmpty == true ? '请输入API URL' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _inaturalistTokenController,
        decoration: const InputDecoration(
          labelText: 'iNaturalist Token',
          border: OutlineInputBorder(),
          hintText: '请输入您的iNaturalist访问令牌',
        ),
        validator: (value) => value?.isEmpty == true ? '请输入访问令牌' : null,
        obscureText: false,
        enableInteractiveSelection: true,
      ),
    ];
  }

  List<Widget> _buildPlantIdSettings() {
    return [
      TextFormField(
        controller: _plantIdApiKeyController,
        decoration: const InputDecoration(
          labelText: 'Plant.id API Key',
          border: OutlineInputBorder(),
          hintText: '请输入您的Plant.id API密钥',
        ),
        validator: (value) => value?.isEmpty == true ? '请输入API密钥' : null,
        obscureText: false,
        enableInteractiveSelection: true,
      ),
    ];
  }

  Widget _buildLLMApiSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'LLM API设置 (文本生成)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _llmApiUrlController,
              decoration: const InputDecoration(
                labelText: 'LLM API 完整地址',
                border: OutlineInputBorder(),
                hintText: 'https://api.openai.com/v1/chat/completions',
                helperText: '请输入完整的API地址，包括版本号和端点路径',
              ),
              validator: (value) => value?.isEmpty == true ? '请输入LLM API完整地址' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _llmApiKeyController,
              decoration: const InputDecoration(
                labelText: 'LLM API Key',
                border: OutlineInputBorder(),
                hintText: '请输入LLM API密钥',
              ),
              validator: (value) => value?.isEmpty == true ? '请输入API密钥' : null,
              obscureText: false,
              enableInteractiveSelection: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _llmModelController,
              decoration: const InputDecoration(
                labelText: 'LLM 模型',
                border: OutlineInputBorder(),
                hintText: 'gpt-4',
              ),
              validator: (value) => value?.isEmpty == true ? '请输入模型名称' : null,
            ),
            const SizedBox(height: 16),
            // 添加测试按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTestingLLM ? null : _testLLMApi,
                icon: _isTestingLLM
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_protected_setup),
                label: Text(_isTestingLLM ? '测试中...' : '测试LLM API连接'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVLMApiSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.visibility,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'VLM API设置 (图像理解)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vlmApiUrlController,
              decoration: const InputDecoration(
                labelText: 'VLM API 完整地址',
                border: OutlineInputBorder(),
                hintText: 'https://api.openai.com/v1/chat/completions',
                helperText: '请输入完整的API地址，包括版本号和端点路径',
              ),
              validator: (value) => value?.isEmpty == true ? '请输入VLM API完整地址' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vlmApiKeyController,
              decoration: const InputDecoration(
                labelText: 'VLM API Key',
                border: OutlineInputBorder(),
                hintText: '请输入VLM API密钥',
              ),
              validator: (value) => value?.isEmpty == true ? '请输入API密钥' : null,
              obscureText: false,
              enableInteractiveSelection: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vlmModelController,
              decoration: const InputDecoration(
                labelText: 'VLM 模型',
                border: OutlineInputBorder(),
                hintText: 'gpt-4-vision-preview',
              ),
              validator: (value) => value?.isEmpty == true ? '请输入模型名称' : null,
            ),
            const SizedBox(height: 16),
            // 添加测试按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTestingVLM ? null : _testVLMApi,
                icon: _isTestingVLM
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_protected_setup),
                label: Text(_isTestingVLM ? '测试中...' : '测试VLM API连接'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherApiSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weather API设置',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weatherApiUrlController,
              decoration: const InputDecoration(
                labelText: 'Weather API URL',
                border: OutlineInputBorder(),
                hintText: 'https://api.weatherapi.com/v1',
              ),
              validator: (value) => value?.isEmpty == true ? '请输入Weather API URL' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weatherApiKeyController,
              decoration: const InputDecoration(
                labelText: 'Weather API Key',
                border: OutlineInputBorder(),
                hintText: '请输入Weather API密钥',
              ),
              validator: (value) => value?.isEmpty == true ? '请输入API密钥' : null,
              obscureText: false,
              enableInteractiveSelection: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final settingsProvider = context.read<SettingsProvider>();

    // 保存植物识别API类型
    await settingsProvider.updatePlantIdentificationApiType(_selectedPlantApiType);

    // 保存iNaturalist设置
    await settingsProvider.updateINaturalistSettings(
      apiUrl: _inaturalistUrlController.text,
      token: _inaturalistTokenController.text,
    );

    // 保存LLM设置
    await settingsProvider.updateLLMSettings(
      apiUrl: _llmApiUrlController.text,
      apiKey: _llmApiKeyController.text,
      model: _llmModelController.text,
    );

    // 保存VLM设置
    await settingsProvider.updateVLMSettings(
      apiUrl: _vlmApiUrlController.text,
      apiKey: _vlmApiKeyController.text,
      model: _vlmModelController.text,
    );

    // 保存Plant.id设置
    await settingsProvider.updatePlantIdSettings(
      apiKey: _plantIdApiKeyController.text,
    );

    // 保存Weather设置
    await settingsProvider.updateWeatherSettings(
      apiKey: _weatherApiKeyController.text,
      apiUrl: _weatherApiUrlController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
    }
  }

  // 添加测试LLM API的方法
  Future<void> _testLLMApi() async {
    setState(() {
      _isTestingLLM = true;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      final result = await settingsProvider.testLLMApi(
        apiUrl: _llmApiUrlController.text,
        apiKey: _llmApiKeyController.text,
        model: _llmModelController.text,
      );

      if (mounted) {
        _showTestResult('LLM API测试结果', result);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTestingLLM = false;
        });
      }
    }
  }

  // 添加测试VLM API的方法
  Future<void> _testVLMApi() async {
    setState(() {
      _isTestingVLM = true;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      final result = await settingsProvider.testVLMApi(
        apiUrl: _vlmApiUrlController.text,
        apiKey: _vlmApiKeyController.text,
        model: _vlmModelController.text,
      );

      if (mounted) {
        _showTestResult('VLM API测试结果', result);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTestingVLM = false;
        });
      }
    }
  }

  // 显示测试结果的方法
  void _showTestResult(String title, Map<String, dynamic> result) {
    final bool success = result['success'] ?? false;
    final String message = result['message'] ?? '未知错误';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (success && result['response'] != null) ...[
              const SizedBox(height: 16),
              const Text('API响应:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result['response'].toString(),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
