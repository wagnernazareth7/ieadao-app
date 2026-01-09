import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/user_model.dart'; // Usando UserModel para listas

/// Provider que retorna a lista de todos os utilizadores (membros) da igreja.
final membersProvider = StreamProvider<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => UserModel.fromFirestore(doc)) // Usando o método correto do UserModel
      .toList());
});
