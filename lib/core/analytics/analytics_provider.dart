import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// PROVIDER REATIVO: Escuta o total de membros em tempo real
final totalMembersProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('membros')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((snap) => snap.docs.length);
});

/// PROVIDER REATIVO: Escuta o total de arrecadação do mês em tempo real
final monthlyDonationsProvider = StreamProvider<double>((ref) {
  return FirebaseFirestore.instance
      .collection('donations')
      .snapshots()
      .map((snap) => snap.docs.fold(0.0, (sum, doc) => sum + (doc.data()['amount'] ?? 0.0)));
});

// Outros providers simplificados para serem reativos conforme necessário
final totalEventsProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('eventos')
      .snapshots()
      .map((snap) => snap.docs.length);
});
