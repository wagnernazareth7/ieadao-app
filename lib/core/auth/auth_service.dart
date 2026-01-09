import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream de autenticação (Firebase User)
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Retorna o utilizador completo com dados do Firestore
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromMap(doc.id, doc.data()!);
  }

  /// Login com tratamento de erro real
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Lança a mensagem de erro específica do Firebase
      throw Exception(e.message ?? 'Erro ao fazer login');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
