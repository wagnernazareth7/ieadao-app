import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/role.dart';
import 'current_user_provider.dart';

final roleProvider = StreamProvider<Role?>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      
      return FirebaseFirestore.instance
          .collection('roles')
          .doc(user.roleId)
          .snapshots()
          .map((doc) => doc.exists ? Role.fromMap(doc.id, doc.data()!) : null);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});
