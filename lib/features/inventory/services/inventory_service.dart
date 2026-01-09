import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item_model.dart';

class InventoryService {
  final _db = FirebaseFirestore.instance.collection('inventory');

  /// Escuta a lista de património (ordenada por categoria)
  Stream<List<InventoryItem>> watchInventory() {
    return _db.orderBy('category').snapshots().map(
      (snap) => snap.docs.map((doc) => InventoryItem.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// Adiciona ou atualiza um item no inventário
  Future<void> saveItem(InventoryItem item) async {
    if (item.id.isEmpty) {
      await _db.add(item.toMap());
    } else {
      await _db.doc(item.id).update(item.toMap());
    }
  }

  /// Remove permanentemente um item (apenas Admin)
  Future<void> deleteItem(String id) async {
    await _db.doc(id).delete();
  }
}
