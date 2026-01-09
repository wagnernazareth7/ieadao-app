import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/donation_model.dart';
import '../../core/audit/audit_service.dart';
import '../notifications/notification_service.dart'; // NOVO IMPORT
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance;

final allDonationsProvider = StreamProvider<List<Donation>>((ref) {
  return _firestore
      .collection('donations')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Donation.fromMap(doc.id, doc.data())).toList());
});

class DonationController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _audit = AuditService();
  final _notifications = NotificationService(); // INICIALIZA SERVIÇO

  Future<void> addDonation({
    required String memberId,
    required String memberName,
    required double amount,
    required String type,
  }) async {
    final donation = Donation(
      id: '',
      memberId: memberId,
      memberName: memberName,
      amount: amount,
      type: type,
      date: DateTime.now(),
    );

    // 1. Grava a doação no Firestore
    await _db.collection('donations').add(donation.toMap());

    // 2. DISPARA NOTIFICAÇÃO INTELIGENTE PARA LÍDERES (Admin, Secretaria, Direção)
    await _notifications.notifyDonationRecieved(
      donorName: memberName,
      category: type,
      amount: amount,
    );

    // 3. REGISTRO NA AUDITORIA
    final user = FirebaseAuth.instance.currentUser;
    await _audit.log(
      userId: user?.uid ?? 'system',
      userName: user?.email?.split('@')[0] ?? 'Membro',
      action: 'OFERTA_RECEBIDA',
      module: 'Financeiro',
      description: 'Oferta de $amount MZN registrada por $memberName (Categoria: $type)',
    );
  }
}

final donationControllerProvider = Provider((ref) => DonationController());
