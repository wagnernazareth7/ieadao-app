import 'package:flutter/material.dart';
import '../../ai_assistant/models/ai_message_model.dart';
import '../../../core/ai/biblical_ai_service.dart';
import '../../../core/theme/app_colors.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<AiMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Mensagem de boas-vindas inicial (Vínculo)
    _messages.add(AiMessage(
      text: "Olá! Eu sou a Luz, seu assistente bíblico. Como posso te apoiar ou qual versículo você gostaria de meditar hoje?",
      role: MessageRole.ai,
      createdAt: DateTime.now(),
    ));
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(AiMessage(text: text, role: MessageRole.user, createdAt: DateTime.now()));
      _textCtrl.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      // CHAMADA AO NOVO MOTOR HUGGING FACE
      final response = await BiblicalAIService.ask(text);

      if (mounted) {
        setState(() {
          _messages.add(AiMessage(text: response, role: MessageRole.ai, createdAt: DateTime.now()));
          _isTyping = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(AiMessage(
            text: "Não foi possível responder agora. Por favor, verifique sua conexão espiritual.", 
            role: MessageRole.ai, 
            createdAt: DateTime.now()
          ));
          _isTyping = false;
        });
      }
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Text('Luz - IA Bíblica'),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _AiMessageBubble(message: msg);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('A Luz está refletindo na Palavra...', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey)),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, 
        border: Border(top: BorderSide(color: Colors.grey.shade200))
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              decoration: const InputDecoration(hintText: 'Pergunte sobre a Bíblia...', border: InputBorder.none),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.primary),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _AiMessageBubble extends StatelessWidget {
  final AiMessage message;
  const _AiMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAi = message.role == MessageRole.ai;
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAi ? AppColors.primary.withOpacity(0.05) : AppColors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isAi ? AppColors.primary.withOpacity(0.1) : AppColors.secondary.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAi ? "LUZ" : "VOCÊ",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAi ? AppColors.primary : AppColors.secondary, letterSpacing: 1),
            ),
            const SizedBox(height: 6),
            Text(
              message.text,
              style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
