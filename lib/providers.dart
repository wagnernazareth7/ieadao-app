import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'repositories/auth_repository.dart';
import 'repositories/firestore_repository.dart';

// Auth
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(FirebaseAuth.instance);
});

// Firestore
final firestoreProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepositoryImpl(FirebaseFirestore.instance);
});
