import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'models/notification_model.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Inicializa as notificações e regista o token do utilizador
  Future<void> init(String userId) async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true, badge: true, sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _fcm.getToken();
        if (token != null) {
          await _db.collection('users').doc(userId).update({
            'fcmToken': token,
            'notificationsEnabled': true,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao inicializar notificações: $e');
    }
  }

  /// Dispara uma Notificação Inteligente (Firestore + FCM)
  Future<void> sendSmartNotification({
    required String targetUserId,
    required String title,
    required String body,
    required String type,
  }) async {
    final notification = AppNotification(
      id: '',
      userId: targetUserId,
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
    );

    await _db.collection('notifications').add(notification.toMap());
  }

  /// GATILHO: Notifica líderes sobre uma nova doação recebida
  Future<void> notifyDonationRecieved({
    required String donorName,
    required String category,
    required double amount,
  }) async {
    // 1. Busca todos os usuários que são Admin, Secretaria ou Direção
    final leadersSnapshot = await _db.collection('users')
        .where('roles', arrayContainsAny: ['admin', 'secretaria', 'direcao'])
        .get();

    final currencyFormat = 'MT'; // Exemplo para Moçambique

    for (var doc in leadersSnapshot.docs) {
      await sendSmartNotification(
        targetUserId: doc.id,
        title: '💰 Nova Doação Recebida',
        body: 'O irmão $donorName realizou uma oferta de $amount $currencyFormat na categoria $category.',
        type: 'financeiro',
      );
    }
  }

  /// GATILHO: Notifica quando alguém ora por um pedido
  Future<void> notifyPrayer(String targetUserId, String prayAuthorName) async {
    await sendSmartNotification(
      targetUserId: targetUserId,
      title: '🙏 Resposta à sua Oração',
      body: '$prayAuthorName acabou de orar pelo seu pedido. Deus está no controle!',
      type: 'oracao',
    );
  }

  /// GATILHO: Notifica novos materiais na EBD
  Future<void> notifyEbdUpdate(List<String> studentIds, String className) async {
    for (var id in studentIds) {
      await sendSmartNotification(
        targetUserId: id,
        title: '📖 Nova Lição na EBD',
        body: 'A classe $className tem novo conteúdo disponível. Vamos aprender juntos?',
        type: 'ebd',
      );
    }
  }

  /// GATILHO: Notifica saudade (30 dias de ausência)
  Future<void> notifyAbsence(String targetUserId) async {
    await sendSmartNotification(
      targetUserId: targetUserId,
      title: '❤️ Sentimos sua falta',
      body: 'Já faz 30 dias que não registamos sua presença nos cultos. Esperamos te ver em breve!',
      type: 'ausencia',
    );
  }
}
