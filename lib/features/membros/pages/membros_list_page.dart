import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/membro_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_roles.dart';
import '../../auth/providers/current_user_provider.dart';
import '../models/membro.dart';

class MembrosListPage extends ConsumerStatefulWidget {
  const MembrosListPage({super.key});

  @override
  ConsumerState<MembrosListPage> createState() => _MembrosListPageState();
}

class _MembrosListPageState extends ConsumerState<MembrosListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersListProvider);
    final userAsync = ref.watch(currentUserProvider);
    
    final bool isAdmin = userAsync.value?.roles.contains('admin') ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestão de Membros'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelColor: Colors.white, // CORRIGIDO: Texto Ativo em Branco
          unselectedLabelColor: Colors.white.withValues(alpha: 0.5), // CORRIGIDO: Texto Inativo em Branco Suave
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
          tabs: const [
            Tab(text: 'ATIVOS'),
            Tab(text: 'INATIVOS'),
          ],
        ),
      ),
      floatingActionButton: isAdmin 
        ? FloatingActionButton.extended(
            onPressed: () => context.push('/membros/novo'),
            backgroundColor: AppColors.secondary,
            label: const Text('NOVO CADASTRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.person_add, color: Colors.white),
          )
        : null,
      body: membersAsync.when(
        data: (allMembers) {
          final ativos = allMembers.where((m) => m.active).toList();
          final inativos = allMembers.where((m) => !m.active).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(ativos, isAdmin: isAdmin),
              _buildList(inativos, isInactive: true, isAdmin: isAdmin),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildList(List<Membro> list, {bool isInactive = false, bool isAdmin = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Nenhum membro ${isInactive ? "inativo" : "ativo"} encontrado.', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final member = list[index];
        
        ImageProvider? profileImage;
        if (member.photoUrl != null && member.photoUrl!.startsWith('data:image')) {
          try {
            final base64Str = member.photoUrl!.split(',').last;
            profileImage = MemoryImage(base64Decode(base64Str));
          } catch (_) {}
        } else if (member.photoUrl != null && member.photoUrl!.startsWith('http')) {
          profileImage = NetworkImage(member.photoUrl!);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: (isInactive ? Colors.grey : AppColors.primary).withValues(alpha: 0.1),
              backgroundImage: profileImage,
              child: profileImage == null 
                ? Text(
                    member.firstName.isNotEmpty ? member.firstName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: isInactive ? Colors.grey : AppColors.primary, 
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                    ),
                  )
                : null,
            ),
            title: Text(
              member.nome, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
            ),
            subtitle: Text(
              member.roles.map((r) => AppRoles.getName(r)).join(" • "), 
              style: const TextStyle(fontSize: 10, color: Colors.grey)
            ),
            trailing: isAdmin 
              ? IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: AppColors.primary,
                  onPressed: () => context.push('/membros/${member.id}/edit', extra: member),
                )
              : const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            onTap: () => context.push('/membros/${member.id}'),
          ),
        );
      },
    );
  }
}
