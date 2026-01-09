import 'package:firebase_auth/firebase_auth.dart';
import 'package:ieadao/repositories/auth_repository.dart';

class FakeUser implements User {
  @override
  String get uid => 'test-uid';

  @override
  String? get email => 'test@ieadao.com';

  // resto não é usado → lança erro se alguém chamar
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthRepository implements AuthRepository {
  final User _user = FakeUser();

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() async* {
    yield _user;
  }
}
