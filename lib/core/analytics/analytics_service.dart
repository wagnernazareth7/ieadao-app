import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final _db = FirebaseFirestore.instance;

  Future<int> totalMembers() async {
    final snap = await _db.collection('membros').get();
    return snap.size;
  }

  Future<int> newMembersLast30Days() async {
    final date = DateTime.now().subtract(const Duration(days: 30));
    final snap = await _db
        .collection('membros')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
        .get();
    return snap.size;
  }

  Future<int> totalEvents() async {
    final snap = await _db.collection('eventos').get();
    return snap.size;
  }

  Future<int> totalEbdClasses() async {
    final snap = await _db.collection('ebd_classes').get();
    return snap.size;
  }

  Future<double> totalDonationsMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final snap = await _db
        .collection('donations')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();
    
    double total = 0;
    for (var doc in snap.docs) {
      total += (doc.data()['amount'] ?? 0).toDouble();
    }
    return total;
  }
}
