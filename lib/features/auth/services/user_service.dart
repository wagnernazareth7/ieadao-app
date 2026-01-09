import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/user_model.dart';

class UserService {
  final _users = FirestoreService.firestore.collection('users');

  /// Busca um utilizador pelo UID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Cria um novo documento de utilizador no Firestore
  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  /// Atualização parcial de dados do utilizador
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Desativação lógica do utilizador
  Future<void> deactivateUser(String uid) async {
    await _users.doc(uid).update({'active': false});
  }
}
