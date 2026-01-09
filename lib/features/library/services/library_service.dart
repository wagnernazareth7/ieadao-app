import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/library_item_model.dart';

class LibraryService {
  final _db = FirebaseFirestore.instance.collection('library');

  /// Escuta os itens da biblioteca por categoria
  Stream<List<LibraryItem>> watchLibrary(String? category) {
    Query query = _db.orderBy('createdAt', descending: true);
    
    if (category != null && category != 'Todos') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map(
      (snap) => snap.docs.map((doc) => LibraryItem.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList(),
    );
  }

  /// Adiciona um novo recurso (Permissão Admin/Comunicacao)
  Future<void> addItem(LibraryItem item) async {
    await _db.add(item.toMap());
  }
}
