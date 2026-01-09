import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationController extends StateNotifier<bool> {
  final NotificationService _service;
  final String userId;

  NotificationController(this._service, this.userId) : super(true);

  /// Alterna o estado das notificações no Firestore
  Future<void> toggleNotifications(bool value) async {
    state = value;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'notificationsEnabled': value,
    });
  }
}

final notificationControllerProvider = StateNotifierProvider.family<NotificationController, bool, String>((ref, userId) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationController(service, userId);
});
