import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> authStateChanges();
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;

  FirebaseAuthRepository(this._auth);

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
