import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreRepository {
  Future<void> addData(String collection, Map<String, dynamic> data);
  Stream<List<Map<String, dynamic>>> getCollection(String collection);
}

class FirestoreRepositoryImpl implements FirestoreRepository {
  final FirebaseFirestore firestore;

  FirestoreRepositoryImpl(this.firestore);

  @override
  Future<void> addData(String collection, Map<String, dynamic> data) {
    return firestore.collection(collection).add(data);
  }

  @override
  Stream<List<Map<String, dynamic>>> getCollection(String collection) {
    return firestore.collection(collection).snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
