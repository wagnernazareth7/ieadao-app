import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ieadao/core/constants/app_roles.dart';
import 'package:ieadao/core/models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream de autenticação (Firebase User)
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Retorna o utilizador atual do Firestore com suporte a Multi-Cargos
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final userDoc = await _db.collection('users').doc(firebaseUser.uid).get();
    if (!userDoc.exists) return null;

    return AppUser.fromMap(userDoc.id, userDoc.data()!);
  }

  /// Registro Seguro: Cria Auth + Perfil User + Ficha Membro
  Future<void> register({
    required String email,
    required String password,
    required String gender,
    required String birthDate,
  }) async {
    try {
      // 1. Criar credencial no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Gravar Perfil em 'users' (Estrutura Multi-Cargo)
      final newUser = AppUser(
        uid: uid,
        email: email,
        roles: [AppRoles.member], 
        active: true,
        gender: gender,
        birthDate: birthDate,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(uid).set(newUser.toMap());

      // 3. Gravar Ficha em 'membros' (Administrativo)
      await _db.collection('membros').doc(uid).set({
        'firstName': email.split('@')[0],
        'lastName': 'Novo Cadastro',
        'email': email,
        'phone': '',
        'gender': gender,
        'birthDate': birthDate,
        'roles': [AppRoles.member],
        'role': AppRoles.member,
        'active': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
