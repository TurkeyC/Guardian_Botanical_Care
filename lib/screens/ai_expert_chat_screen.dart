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
import '../themes/app_themes.dart';
import '../widgets/apple_style_widgets.dart';
import '../widgets/apple_animations.dart';
import '../services/ai_chat_service.dart';
import 'dart:async';

class AiExpertChatScreen extends StatefulWidget {
  const AiExpertChatScreen({super.key});

  @override
  State<AiExpertChatScreen> createState() => _AiExpertChatScreenState();
}

class _AiExpertChatScreenState extends State<AiExpertChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiChatService _chatService = AiChatService.instance;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 从Provider获取设置并初始化AI聊天服务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      _chatService.init(settingsProvider: settingsProvider);
    });
    _loadChatHistory();
    _addWelcomeMessage();
  }

  void _loadChatHistory() {
    setState(() {
      _messages = _chatService.chatHistory;
    });
  }

  void _addWelcomeMessage() {
    // 只有在聊天历史为空且服务中也没有消息时才添加欢迎消息
    if (_chatService.chatHistory.isEmpty) {
      final welcomeMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '👋 您好！我是您的AI植物养护专家，很高兴为您服务！\n\n我可以帮助您解决各种植物养护问题：\n• 🌱 浇水施肥指导\n• 🌞 光照环境建议\n• 🍃 病虫害诊断\n• 🌵 植物选择推荐\n\n请随时向我提问，我会为您提供专业的建议！',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _chatService.addMessage(welcomeMessage);
      setState(() {
        _messages = _chatService.chatHistory;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDynamic = settings.currentTheme == AppThemeType.dynamic;
        return isDynamic
            ? _buildDynamicScreen(context)
            : _buildMinimalScreen(context);
      },
    );
  }

  Widget _buildDynamicScreen(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'AI专家解答',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: ParticleBackground(
        particleCount: 20,
        particleColor: Colors.green.withValues(alpha: 0.2),
        particleSize: 1.5,
        child: _buildChatInterface(true),
      ),
    );
  }

  Widget _buildMinimalScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI专家解答'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: _buildChatInterface(false),
    );
  }

  Widget _buildChatInterface(bool isDynamic) {
    return Column(
      children: [
        // 聊天消息列表
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _buildMessageBubble(_messages[index], isDynamic);
            },
          ),
        ),

        // 输入框
        _buildInputArea(isDynamic),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDynamic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // AI头像
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
          ],

          // 消息气泡
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? (isDynamic ? Colors.blue.withValues(alpha: 0.8) : Colors.blue)
                    : (isDynamic
                        ? Colors.black.withValues(alpha: 0.6)
                        : Colors.grey[100]),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: message.isUser
                      ? const Radius.circular(6)
                      : const Radius.circular(20),
                  bottomLeft: !message.isUser
                      ? const Radius.circular(6)
                      : const Radius.circular(20),
                ),
                border: isDynamic
                    ? Border.all(
                        color: message.isUser
                            ? Colors.blue.withValues(alpha: 0.5)
                            : Colors.green.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDynamic ? 0.2 : 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isLoading) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDynamic ? Colors.green : Colors.green[600]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'AI正在思考中...',
                          style: TextStyle(
                            color: isDynamic ? Colors.white70 : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      message.content,
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white
                            : (isDynamic ? Colors.white : Colors.black87),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white70
                            : (isDynamic ? Colors.white60 : Colors.grey[500]),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 12),
            // 用户头像
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDynamic ? Colors.blue.withValues(alpha: 0.8) : Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDynamic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDynamic
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: isDynamic
            ? Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              )
            : null,
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 输入框
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDynamic
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isDynamic
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.grey[300]!,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: !_isLoading,
                  maxLines: null,
                  style: TextStyle(
                    color: isDynamic ? Colors.black54 : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: '请输入您的植物问题...',
                    hintStyle: TextStyle(
                      color: isDynamic
                          ? Colors.black26.withValues(alpha: 0.6)
                          : Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 发送按钮
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isLoading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                color: _isLoading ? Colors.grey : null,
                boxShadow: _isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: IconButton(
                onPressed: _isLoading ? null : _sendMessage,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    // 清空输入框
    _messageController.clear();

    // 添加用户消息
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _chatService.addMessage(userMessage);

    // 添加加载中的AI消息
    final loadingId = '${DateTime.now().millisecondsSinceEpoch}_loading';
    final loadingMessage = ChatMessage(
      id: loadingId,
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    _chatService.addMessage(loadingMessage);

    setState(() {
      _messages = _chatService.chatHistory;
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // 调用AI服务
      final aiResponse = await _chatService.sendMessage(message);

      // 替换加载消息为实际回复
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _chatService.removeMessage(loadingId);
      _chatService.addMessage(aiMessage);

      setState(() {
        _messages = _chatService.chatHistory;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      // 错误处理
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '抱歉，AI服务暂时不可用：${e.toString()}\n\n请稍后重试或联系技术支持。',
        isUser: false,
        timestamp: DateTime.now(),
      );

      _chatService.removeMessage(loadingId);
      _chatService.addMessage(errorMessage);

      setState(() {
        _messages = _chatService.chatHistory;
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清空聊天记录'),
          content: const Text('确定要清空所有聊天记录吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _chatService.clearHistory();
                setState(() {
                  _messages = [];
                });
                _addWelcomeMessage();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
