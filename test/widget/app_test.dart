import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ieadao/providers.dart';

import '../mocks/mock_auth_repository.dart';
import '../mocks/mock_firestore_repository.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        firestoreProvider.overrideWithValue(MockFirestoreRepository()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('Auth mock funciona', () {
    final auth = container.read(authRepositoryProvider);
    expect(auth.currentUser, isNotNull);
    expect(auth.currentUser!.email, 'test@ieadao.com');
  });

  test('Firestore mock funciona', () async {
    final repo = container.read(firestoreProvider);
    await repo.addData('users', {'name': 'Nazareth'});
    final data = await repo.getCollection('users').first;
    expect(data.first['name'], 'Nazareth');
  });
}
