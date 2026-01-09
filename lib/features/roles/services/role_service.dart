import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/role.dart';

class RoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Role?> getRoleById(String roleId) async {
    final doc = await _firestore.collection('roles').doc(roleId).get();
    if (!doc.exists) return null;
    return Role.fromMap(doc.id, doc.data()!);
  }
}
