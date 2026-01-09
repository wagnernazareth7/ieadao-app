import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/firebase/firebase_providers.dart';

final authControllerProvider =
StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthController(auth, firestore);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthController(this._auth, this._firestore) : super(const AsyncData(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();

    try {

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Após o login, verifica se o usuário existe no Firestore
      final user = _auth.currentUser;
      if (user != null) {
        final doc = _firestore.collection('users').doc(user.uid);
        final snapshot = await doc.get();

        if (!snapshot.exists) {
          await doc.set({
            'email': user.email,
            'nome': 'Utilizador',
            'criadoEm': DateTime.now().toIso8601String(),
          });
        }
      }

      state = const AsyncData(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(e.message ?? 'Erro ao autenticar', st);
    } catch (e, st) {
      state = AsyncError('Erro inesperado: $e', st);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
