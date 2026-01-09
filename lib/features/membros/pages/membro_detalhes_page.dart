import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ieadao/core/constants/app_roles.dart';
import '../models/membro.dart';
import '../providers/membro_providers.dart';
import '../../auth/providers/current_user_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

class MembroDetalhesPage extends ConsumerWidget {
  final String membroId;
  const MembroDetalhesPage({super.key, required this.membroId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membroAsync = ref.watch(memberByIdProvider(membroId));
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ficha do Membro'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: membroAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (membro) {
          if (membro == null) return const Center(child: Text('Membro não encontrado.'));

          final userRoles = currentUserAsync.value?.roles.map((r) => r.toLowerCase()).toList() ?? [];
          final bool canEdit = userRoles.contains('admin') || userRoles.contains('administrador');

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(membro),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('JORNADA ESPIRITUAL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11, letterSpacing: 1.2)),
                      const SizedBox(height: 12),
                      _buildSpiritualCard(membro),

                      const SizedBox(height: 32),
                      const Text('DADOS DE CONTACTO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11, letterSpacing: 1.2)),
                      const SizedBox(height: 12),
                      _buildPersonalCard(membro),
                      
                      const SizedBox(height: 40),
                      
                      if (canEdit)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/membros/${membro.id}/edit', extra: membro),
                            icon: const Icon(Icons.edit_outlined, color: Colors.white),
                            label: const Text('EDITAR PERFIL COMPLETO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Membro membro) {
    ImageProvider? image;
    
    // CORREÇÃO SÉNIOR: Suporte para Base64 e Network
    if (membro.photoUrl != null && membro.photoUrl!.startsWith('data:image')) {
      try {
        final base64Str = membro.photoUrl!.split(',').last;
        image = MemoryImage(base64Decode(base64Str));
      } catch (_) {}
    } else if (membro.photoUrl != null && membro.photoUrl!.startsWith('http')) {
      image = NetworkImage(membro.photoUrl!);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: image,
                child: image == null 
                  ? Text(membro.firstName.isNotEmpty ? membro.firstName[0].toUpperCase() : '?', 
                      style: const TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold))
                  : null,
              ),
              if (membro.isBaptized)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.cyanAccent,
                    child: Icon(Icons.water_drop, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(membro.nome, style: AppTextStyles.heading.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(membro.roles.map((r) => AppRoles.getName(r)).join(" • ").toUpperCase(), 
            style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSpiritualCard(Membro membro) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(label: 'Fase Ministerial', value: _formatStatus(membro.spiritualStatus), icon: Icons.auto_awesome, color: Colors.orange),
            const Divider(),
            _DetailRow(label: 'Batismo', value: membro.isBaptized ? 'Batizado nas Águas' : 'Não Batizado', icon: Icons.water_drop, color: Colors.cyan),
            if (membro.isBaptized && membro.baptismDate.isNotEmpty) ...[
              const Divider(),
              _DetailRow(label: 'Data do Batismo', value: membro.baptismDate, icon: Icons.event_available, color: Colors.blue),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalCard(Membro membro) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(label: 'E-mail', value: membro.email, icon: Icons.email_outlined),
            const Divider(),
            _DetailRow(label: 'Telemóvel', value: '+258 ${membro.phone}', icon: Icons.phone_android_outlined),
            const Divider(),
            _DetailRow(label: 'Género', value: membro.gender, icon: Icons.wc_outlined),
          ],
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'novo_convertido': return 'Novo Convertido';
      case 'em_discipulado': return 'Em Discipulado';
      default: return 'Membro Pleno';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  const _DetailRow({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
