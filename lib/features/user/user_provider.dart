import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/firebase/firestore_providers.dart';
import 'user_model.dart';

final userProvider = StreamProvider<UserModel?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = FirebaseAuth.instance;

  final user = auth.currentUser;
  if (user == null) return const Stream.empty();

  return firestore
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  });
});
