import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/expense_model.dart';

class ExpenseService {
  final _db = FirebaseFirestore.instance.collection('expenses');

  /// Regista uma nova saída de valor
  Future<void> addExpense(Expense expense) async {
    await _db.add(expense.toMap());
  }

  /// Escuta todas as despesas em tempo real
  Stream<List<Expense>> watchExpenses() {
    return _db
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Expense.fromMap(doc.id, doc.data())).toList());
  }

  /// CORREÇÃO SÉNIOR: Calcula o total gasto histórico com tipagem estrita
  Future<double> getTotalExpenses() async {
    final snap = await _db.get();
    return snap.docs.fold<double>(0.0, (double sum, doc) {
      final data = doc.data();
      final double amount = (data['amount'] ?? 0.0).toDouble();
      return sum + amount;
    });
  }
}
