import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ieadao/core/theme/app_colors.dart';
import 'package:ieadao/core/theme/app_text_styles.dart';
import '../auth/providers/current_user_provider.dart';
import 'evento_controller.dart';
import 'evento_model.dart';

class EventoListPage extends ConsumerWidget {
  const EventoListPage({super.key});

  bool _canManage(List<String> roles) {
    final normalized = roles.map((r) => r.toLowerCase()).toList();
    return normalized.contains('admin') || 
           normalized.contains('direcao') || 
           normalized.contains('secretaria') || 
           normalized.contains('comunicacao');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(todosEventosProvider);
    final userAsync = ref.watch(currentUserProvider);
    final userRoles = userAsync.value?.roles ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agenda da Igreja'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: _canManage(userRoles) 
        ? FloatingActionButton(
            backgroundColor: AppColors.secondary,
            onPressed: () => context.push('/evento_form'),
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
      body: eventosAsync.when(
        data: (eventos) {
          if (eventos.isEmpty) return const Center(child: Text('Nenhum evento agendado.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final e = eventos[index];
              final hora = DateFormat('HH:mm').format(e.data);
              final isLider = _canManage(userRoles);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  // CORREÇÃO SÉNIOR: Agora leva para o Detalhe com Confirmação e Estatísticas
                  onTap: () => context.push('/agenda/${e.id}'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        // BLOCO DA DATA
                        _buildDateBadge(e.data),
                        const SizedBox(width: 16),
                        
                        // INFORMAÇÕES
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.titulo, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text('$hora • ${e.local}', 
                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        
                        // BOTÃO DE GESTÃO RÁPIDA (Só para líderes)
                        if (isLider)
                          IconButton(
                            icon: const Icon(Icons.edit_note, color: Colors.grey, size: 20),
                            onPressed: () => context.push('/evento_form', extra: e),
                          )
                        else
                          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildDateBadge(DateTime data) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(data.day.toString(), 
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
          Text(DateFormat('MMM').format(data).toUpperCase(), 
            style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
