import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = FirebaseAuth.instance;
  
  // O StreamProvider do Riverpod reconstrói quando o estado muda
  return auth.authStateChanges().asyncExpand((user) {
    if (user == null) return Stream.value(null);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null);
  });
});
