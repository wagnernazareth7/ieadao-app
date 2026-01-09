import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/notice_model.dart';
import '../../../core/models/notice_reply_model.dart';

class NoticeDetailPage extends ConsumerStatefulWidget {
  final String noticeId;
  const NoticeDetailPage({super.key, required this.noticeId});

  @override
  ConsumerState<NoticeDetailPage> createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends ConsumerState<NoticeDetailPage> {
  final _replyCtrl = TextEditingController();
  bool _isSending = false;

  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('notices')
          .doc(widget.noticeId)
          .collection('replies')
          .add({
        'userId': user?.uid ?? 'anon',
        'userName': user?.email?.split('@')[0] ?? 'Membro',
        'content': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _replyCtrl.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao responder: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalhes do Aviso'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. O CONTEÚDO DO AVISO
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('notices').doc(widget.noticeId).get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LinearProgressIndicator();
                      final notice = Notice.fromMap(snapshot.data!.id, snapshot.data!.data() as Map<String, dynamic>);
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notice.title, style: AppTextStyles.heading.copyWith(fontSize: 22)),
                          const SizedBox(height: 8),
                          Text('Publicado em ${DateFormat('dd/MM/yyyy').format(notice.date)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const Divider(height: 32),
                          Text(notice.content, style: const TextStyle(fontSize: 15, height: 1.5)),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                  const Text('RESPOSTAS E COMENTÁRIOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary, letterSpacing: 1.2)),
                  const SizedBox(height: 16),

                  // 2. LISTA DE RESPOSTAS (Realtime)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('notices')
                        .doc(widget.noticeId)
                        .collection('replies')
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final replies = snapshot.data!.docs;

                      if (replies.isEmpty) return const Text('Seja o primeiro a responder.', style: TextStyle(color: Colors.grey, fontSize: 12));

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: replies.length,
                        itemBuilder: (context, i) {
                          final r = NoticeReply.fromMap(replies[i].id, replies[i].data() as Map<String, dynamic>);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                                    Text(DateFormat('HH:mm').format(r.createdAt), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(r.content, style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 3. CAMPO DE RESPOSTA FIXO NO FUNDO
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyCtrl,
                decoration: InputDecoration(
                  hintText: 'Escreva sua resposta...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _isSending 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _sendReply,
                ),
          ],
        ),
      ),
    );
  }
}
