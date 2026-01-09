import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/role.dart';

final rolesProvider = StreamProvider<List<Role>>((ref) {
  return FirebaseFirestore.instance.collection('roles').snapshots().map(
    (snap) => snap.docs.map((doc) => Role.fromMap(doc.id, doc.data())).toList(),
  );
});

class RolesListPage extends ConsumerWidget {
  const RolesListPage({super.key});

  Future<void> _togglePermission(String roleId, String permissionKey, bool newValue) async {
    try {
      await FirebaseFirestore.instance.collection('roles').doc(roleId).update({
        'permissions.$permissionKey': newValue,
      });
    } catch (e) {
      debugPrint('Erro ao atualizar permissão: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Cargos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: rolesAsync.when(
        data: (roles) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: roles.length,
          itemBuilder: (context, index) {
            final role = roles[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(role.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('ID: ${role.id}', style: AppTextStyles.caption),
                children: [
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: role.permissions.entries.map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(p.key, style: AppTextStyles.body),
                            Switch(
                              value: p.value,
                              activeColor: AppColors.secondary,
                              onChanged: (val) => _togglePermission(role.id, p.key, val),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  )
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
