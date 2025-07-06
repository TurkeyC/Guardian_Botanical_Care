import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../themes/app_themes.dart';
import 'apple_style_showcase_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
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
                // 皮肤选择
                _buildThemeSection(settingsProvider),
                const SizedBox(height: 24),

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
                const SizedBox(height: 24),

                // 苹果风格展示按钮
                _buildAppleStyleShowcaseButton(),

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

  Widget _buildThemeSection(SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '皮肤设置',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 主题选择卡片
            ...AppThemeType.values.map((themeType) {
              final isSelected = settingsProvider.currentTheme == themeType;
              return Container(
                key: ValueKey('theme_${themeType.name}'), // 添加唯一key避免GlobalKey冲突
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () async {
                    await settingsProvider.updateTheme(themeType);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surface,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // 防止布局溢出
                      children: [
                        // 主题预览图标
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: _getThemeGradient(themeType),
                          ),
                          child: Icon(
                            _getThemeIcon(themeType),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 主题信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // 防止垂直溢出
                            children: [
                              Text(
                                AppThemes.getThemeName(themeType),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                  inherit: true, // 确保inherit一致性
                                ),
                                overflow: TextOverflow.ellipsis, // 防止文本溢出
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppThemes.getThemeDescription(themeType),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  inherit: true, // 确保inherit一致性
                                ),
                                overflow: TextOverflow.ellipsis, // 防止文本溢出
                                maxLines: 2, // 限制最大行数
                              ),
                            ],
                          ),
                        ),

                        // 选中指示器
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        else
                          Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(), // 确保返回List而不是Iterable
          ],
        ),
      ),
    );
  }

  Gradient _getThemeGradient(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.minimal:
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemeType.dynamic:
        return const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF34C759)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getThemeIcon(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.minimal:
        return Icons.minimize_outlined;
      case AppThemeType.dynamic:
        return Icons.auto_awesome;
    }
  }

  Widget _buildPlantIdentificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '植物识别设置',
              style: Theme.of(context).textTheme.titleLarge,
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
        obscureText: true,
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
        obscureText: true,
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
            Text(
              'LLM API设置 (文本生成)',
              style: Theme.of(context).textTheme.titleLarge,
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
              obscureText: true,
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
            Text(
              'VLM API设置 (���像理解)',
              style: Theme.of(context).textTheme.titleLarge,
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
              obscureText: true,
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
            Text(
              'Weather API设置',
              style: Theme.of(context).textTheme.titleLarge,
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
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleStyleShowcaseButton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '苹果风格展示',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '体验全新的苹果2.5D灵动风格界面，包含毛玻璃效果、渐变色块、动画效果等',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AppleStyleShowcasePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('查看演示'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
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
}
