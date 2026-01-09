import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/message_model.dart';

final chatControllerProvider = Provider((ref) => ChatController());

final chatMessagesProvider = StreamProvider.family<List<Message>, String>((ref, channel) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(channel)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Message.fromMap(doc.id, doc.data())).toList());
});

class ChatController {
  final _db = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String channel,
    required String userId,
    required String userName,
    required String content,
  }) async {
    final messageData = {
      'channel': channel,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db.collection('chats').doc(channel).collection('messages').add(messageData);
  }

  Future<void> deleteMessage(String channel, String messageId) async {
    await _db.collection('chats').doc(channel).collection('messages').doc(messageId).delete();
  }
}
