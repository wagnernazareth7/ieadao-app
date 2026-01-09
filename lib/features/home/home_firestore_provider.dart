import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/evento.dart';

final homeEventosProvider = StreamProvider<List<Evento>>((ref) {
  final collection = FirebaseFirestore.instance.collection('eventos');
  return collection.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => Evento.fromMap(doc.id, doc.data())).toList());
});
