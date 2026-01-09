import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ieadao/core/models/app_user.dart';
import 'auth_state_provider.dart'; 

/// PROVIDER REATIVO SÉNIOR: Escuta mudanças de perfil em tempo real
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      // CORREÇÃO: Usamos snapshots() para escutar mudanças de cargo em tempo real
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;
            return AppUser.fromMap(doc.id, doc.data()!);
          });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
