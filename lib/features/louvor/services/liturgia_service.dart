import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_of_service_model.dart';

class LiturgiaService {
  final _db = FirebaseFirestore.instance.collection('order_of_service');

  /// Escuta todos os roteiros do dia atual
  Stream<List<OrderOfService>> watchTodayServices() {
    final hoje = DateTime.now();
    final inicioDia = DateTime(hoje.year, hoje.month, hoje.day);
    
    return _db
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => OrderOfService.fromMap(doc.id, doc.data())).toList());
  }

  /// Cria um novo roteiro personalizado
  Future<void> startNewService(String title) async {
    final defaultItems = [
      OrderOfServiceItem(label: 'Oração Inicial'),
      OrderOfServiceItem(label: 'Louvor Congregacional'),
      OrderOfServiceItem(label: 'Dízimos e Ofertas'),
      OrderOfServiceItem(label: 'Ministração da Palavra'),
      OrderOfServiceItem(label: 'Bênção Apostólica'),
    ];

    final newService = OrderOfService(
      id: '',
      title: title,
      date: DateTime.now(),
      items: defaultItems,
      isLive: true,
    );

    await _db.add(newService.toMap());
  }

  /// Salva qualquer alteração no roteiro (Mudança de nome, adição/remoção de itens)
  Future<void> updateFullService(OrderOfService service) async {
    await _db.doc(service.id).update(service.toMap());
  }

  /// Alterna o estado de conclusão de um item
  Future<void> toggleItem(String serviceId, List<OrderOfServiceItem> items, int index) async {
    final currentItem = items[index];
    items[index] = OrderOfServiceItem(
      label: currentItem.label,
      isCompleted: !currentItem.isCompleted,
      completedAt: !currentItem.isCompleted ? DateTime.now() : null,
    );

    await _db.doc(serviceId).update({
      'items': items.map((i) => i.toMap()).toList(),
    });
  }

  Future<void> deleteService(String id) async {
    await _db.doc(id).delete();
  }
}
