import 'package:ieadao/repositories/firestore_repository.dart';

class MockFirestoreRepository implements FirestoreRepository {
  final _data = <String, List<Map<String, dynamic>>>{};

  @override
  Future<void> addData(String collection, Map<String, dynamic> data) async {
    _data.putIfAbsent(collection, () => []).add(data);
  }

  @override
  Stream<List<Map<String, dynamic>>> getCollection(String collection) async* {
    yield _data[collection] ?? [];
  }
}
