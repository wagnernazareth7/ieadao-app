import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ieadao/core/constants/app_roles.dart';
import 'package:ieadao/core/models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    final userDoc = await _db.collection('users').doc(firebaseUser.uid).get();
    if (!userDoc.exists) return null;
    return AppUser.fromMap(userDoc.id, userDoc.data()!);
  }

  /// Registro Evoluído: Captura Nome e Apelido reais
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required String birthDate,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 1. Gravar Perfil em 'users'
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'roles': [AppRoles.member],
        'active': true,
        'gender': gender,
        'birthDate': birthDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Gravar Ficha em 'membros' (Sincronizado)
      await _db.collection('membros').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
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
