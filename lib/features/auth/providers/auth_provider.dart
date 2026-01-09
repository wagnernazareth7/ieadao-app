import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provider que observa as mudanças no estado de autenticação do Firebase.
/// Retorna um Stream com o User atual ou null se não estiver logado.
final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
