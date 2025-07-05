import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

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
  final _openaiUrlController = TextEditingController();
  final _openaiKeyController = TextEditingController();
  final _visionModelController = TextEditingController();
  final _textModelController = TextEditingController();

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

    _inaturalistUrlController.text = settingsProvider.inaturalistApiUrl;
    _inaturalistTokenController.text = settingsProvider.inaturalistToken;
    _openaiUrlController.text = settingsProvider.openaiApiUrl;
    _openaiKeyController.text = settingsProvider.openaiApiKey;
    _visionModelController.text = settingsProvider.visionModel;
    _textModelController.text = settingsProvider.textModel;
  }

  @override
  void dispose() {
    _inaturalistUrlController.dispose();
    _inaturalistTokenController.dispose();
    _openaiUrlController.dispose();
    _openaiKeyController.dispose();
    _visionModelController.dispose();
    _textModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('应用设置'),
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
                // iNaturalist 设置
                _buildSectionTitle('🌿 iNaturalist API 设置'),
                _buildTextField(
                  controller: _inaturalistUrlController,
                  label: 'API 地址',
                  hint: 'https://api.inaturalist.org',
                  validator: _validateUrl,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _inaturalistTokenController,
                  label: 'API Token',
                  hint: '请输入您的 iNaturalist API Token',
                  obscureText: true,
                  validator: _validateRequired,
                ),

                const SizedBox(height: 32),

                // OpenAI 设置
                _buildSectionTitle('🤖 OpenAI API 设置'),
                _buildTextField(
                  controller: _openaiUrlController,
                  label: 'API 地址',
                  hint: 'https://api.openai.com',
                  validator: _validateUrl,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _openaiKeyController,
                  label: 'API Key',
                  hint: '请输入您的 OpenAI API Key',
                  obscureText: true,
                  validator: _validateRequired,
                ),

                const SizedBox(height: 32),

                // 模型设置
                _buildSectionTitle('⚙️ 模型设置'),
                _buildTextField(
                  controller: _visionModelController,
                  label: '视觉模型',
                  hint: 'gpt-4-vision-preview',
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _textModelController,
                  label: '文本模型',
                  hint: 'gpt-4',
                  validator: _validateRequired,
                ),

                const SizedBox(height: 32),

                // 说明文档
                _buildHelpSection(),

                const SizedBox(height: 32),

                // 保存按钮
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '保存设置',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    // 这里可以添加切换密码可见性的逻辑
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildHelpSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📖 配置说明',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              '1. iNaturalist Token',
              '请前往 iNaturalist.org 注册账号并获取 API Token',
            ),
            _buildHelpItem(
              '2. OpenAI API Key',
              '请前往 platform.openai.com 获取 API Key',
            ),
            _buildHelpItem(
              '3. API 地址',
              '如使用第三方代理，请修改相应的 API 地址',
            ),
            _buildHelpItem(
              '4. 模型选择',
              '可根据需要选择不同的 GPT 模型版本',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '此字段不能为空';
    }
    return null;
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '此字段不能为空';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAbsolutePath) {
      return '请输入有效的URL地址';
    }
    return null;
  }

  void _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settingsProvider = context.read<SettingsProvider>();

    // 保存 iNaturalist 设置
    await settingsProvider.updateINaturalistSettings(
      apiUrl: _inaturalistUrlController.text.trim(),
      token: _inaturalistTokenController.text.trim(),
    );

    // 保存 OpenAI 设置
    await settingsProvider.updateOpenAISettings(
      apiUrl: _openaiUrlController.text.trim(),
      apiKey: _openaiKeyController.text.trim(),
    );

    // 保存模型设置
    await settingsProvider.updateModelSettings(
      visionModel: _visionModelController.text.trim(),
      textModel: _textModelController.text.trim(),
    );

    if (settingsProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settingsProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
      settingsProvider.clearError();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('设置已保存'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
