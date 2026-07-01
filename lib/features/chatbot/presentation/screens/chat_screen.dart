import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    if (chat.messages.isNotEmpty || chat.isLoading) {
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined, size: 20),
            SizedBox(width: 8),
            Text('CHRONOSIA'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Limpiar conversación',
            onPressed: chat.messages.isEmpty ? null : chat.clear,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Banner de error ─────────────────────────────────────────────
          if (chat.status == ChatStatus.error)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              content: Text(
                chat.errorMessage ?? 'Error desconocido',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              backgroundColor:
                  Theme.of(context).colorScheme.errorContainer,
              actions: [
                TextButton(
                  onPressed: chat.clear,
                  child: const Text('Cerrar'),
                ),
              ],
            ),

          // ── Lista de mensajes ───────────────────────────────────────────
          Expanded(
            child: chat.messages.isEmpty && !chat.isLoading
                ? const _EmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    itemCount: chat.messages.length +
                        (chat.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chat.messages.length) {
                        return const TypingIndicator();
                      }
                      return MessageBubble(
                          message: chat.messages[index]);
                    },
                  ),
          ),

          // ── Input ───────────────────────────────────────────────────────
          ChatInputBar(
            enabled: !chat.isLoading,
            onSend: chat.send,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'CHRONOSIA',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '¿En qué puedo ayudarte?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
