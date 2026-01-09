import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ieadao/core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../membros/providers/membro_providers.dart';

class SecretariaDashboard extends ConsumerWidget {
  const SecretariaDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membrosAsync = ref.watch(membersListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Secretaria Geral'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
            onPressed: () => context.push('/ia-assistente'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await AuthService().logout(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gestão de Membros', 
                    style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 22)),
                  const SizedBox(height: 4),
                  membrosAsync.maybeWhen(
                    data: (list) => Text('Total de ${list.length} membros cadastrados.', 
                      style: const TextStyle(color: Colors.white70)),
                    orElse: () => const Text('Carregando dados...', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tarefas Administrativas', style: AppTextStyles.heading),
                  const SizedBox(height: 16),
                  
                  // GRID SECRETARIA COMPACTO (4 Colunas)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _CompactSecBtn(icon: Icons.people_alt, label: 'Membros', color: Colors.blue, onTap: () => context.push('/membros')),
                      _CompactSecBtn(icon: Icons.person_add, label: 'Novo', color: Colors.green, onTap: () => context.push('/membros/novo')),
                      _CompactSecBtn(icon: Icons.calendar_month, label: 'Agenda', color: Colors.orange, onTap: () => context.push('/agenda')),
                      _CompactSecBtn(icon: Icons.library_books, label: 'Biblioteca', color: Colors.teal, onTap: () => context.push('/biblioteca')),
                      _CompactSecBtn(icon: Icons.volunteer_activism, label: 'Doações', color: Colors.redAccent, onTap: () => context.push('/donations')),
                      _CompactSecBtn(icon: Icons.inventory_2, label: 'Inventário', color: Colors.indigo, onTap: () => context.push('/inventario')),
                      _CompactSecBtn(icon: Icons.campaign, label: 'Avisos', color: Colors.purple, onTap: () => context.push('/comunicados')),
                      _CompactSecBtn(icon: Icons.settings, label: 'Ajustes', color: Colors.grey, onTap: () {}),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Text('Estado do Sistema', style: AppTextStyles.heading),
                  const SizedBox(height: 12),
                  const Card(
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.check_circle, color: Colors.green, size: 18),
                      title: Text('Base de dados sincronizada', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text('Atualizado há instantes', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactSecBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _CompactSecBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, 
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
