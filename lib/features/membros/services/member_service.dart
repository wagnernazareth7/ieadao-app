import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../models/membro.dart';
import '../../../core/audit/audit_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MemberService {
  final _members = FirestoreService.firestore.collection('membros');
  final _audit = AuditService();

  Stream<List<Membro>> watchMembers({bool activeOnly = true}) {
    Query query = _members;
    
    if (activeOnly) {
      query = query.where('active', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => Membro.fromFirestore(doc)).toList();
      
      // CORREÇÃO SÉNIOR: Ordenação com proteção contra strings vazias (evita RangeError)
      list.sort((a, b) {
        final nameA = a.firstName.toLowerCase().trim();
        final nameB = b.firstName.toLowerCase().trim();
        
        // Se ambos vazios, mantém ordem
        if (nameA.isEmpty && nameB.isEmpty) return 0;
        // Se A vazio, move para o fim
        if (nameA.isEmpty) return 1;
        // Se B vazio, mantém A no topo
        if (nameB.isEmpty) return -1;
        
        return nameA.compareTo(nameB);
      });
      
      return list;
    });
  }

  Stream<List<Membro>> watchBirthdaysToday() {
    final today = DateFormat('dd/MM').format(DateTime.now());
    return _members.where('active', isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Membro.fromFirestore(doc))
          .where((m) {
            // Proteção extra para aniversários também
            if (m.birthDate.length < 5) return false;
            return m.birthDate.startsWith(today);
          })
          .toList();
    });
  }

  Future<Membro?> getMemberById(String id) async {
    final doc = await _members.doc(id).get();
    if (!doc.exists) return null;
    return Membro.fromFirestore(doc);
  }

  Future<void> createMember(Membro member) async {
    final docRef = await _members.add(member.toMap());
    final user = FirebaseAuth.instance.currentUser;
    await _audit.log(
      userId: user?.uid ?? 'system',
      userName: user?.email?.split('@')[0] ?? 'Sistema',
      action: 'CADASTRO',
      module: 'Membros',
      description: 'Cadastrou novo membro: ${member.firstName} ${member.lastName}',
    );
  }

  Future<void> updateMember(String id, Map<String, dynamic> data) async {
    await _members.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final user = FirebaseAuth.instance.currentUser;
    await _audit.log(
      userId: user?.uid ?? 'system',
      userName: user?.email?.split('@')[0] ?? 'Sistema',
      action: 'EDIÇÃO',
      module: 'Membros',
      description: 'Alterou dados do membro ID: $id',
    );
  }

  Future<void> deactivateMember(String id) async {
    await _members.doc(id).update({'active': false});
    final user = FirebaseAuth.instance.currentUser;
    await _audit.log(
      userId: user?.uid ?? 'system',
      userName: user?.email?.split('@')[0] ?? 'Sistema',
      action: 'DESATIVAÇÃO',
      module: 'Membros',
      description: 'Desativou o membro ID: $id',
    );
  }
}
