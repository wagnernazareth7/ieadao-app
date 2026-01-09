import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  /// Envia uma mensagem para um canal específico (ex: 'louvor', 'jovens')
  Future<void> sendMessage({
    required String channel,
    required String userId,
    required String userName,
    required String content,
  }) async {
    await _supabase.from('messages').insert({
      'channel': channel,
      'user_id': userId,
      'user_name': userName,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Escuta mensagens em tempo real de um canal
  Stream<List<Map<String, dynamic>>> watchMessages(String channel) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('channel', channel)
        .order('created_at', ascending: false)
        .limit(50);
  }
}
