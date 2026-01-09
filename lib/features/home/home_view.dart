import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../evento/evento_controller.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(todosEventosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. BANNER DE BOAS-VINDAS (SliverAppBar com design moderno)
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text('IEADAO', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
              background: Stack(
                fit: StackFit.expand, // CORRIGIDO: StackOrigin -> StackFit
                children: [
                  // Camada de cor degradê sobre o banner
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                  ),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.church, size: 48, color: Colors.white70),
                          SizedBox(height: 8),
                          Text('Seja bem-vindo à nossa Igreja', 
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. CONTEÚDO PRINCIPAL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Próximos Cultos e Eventos', style: AppTextStyles.heading),
                  const SizedBox(height: 16),
                  
                  // LISTA DE EVENTOS DINÂMICA
                  eventosAsync.when(
                    data: (eventos) {
                      if (eventos.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text('Nenhum evento agendado para breve.'),
                          ),
                        );
                      }

                      return Column(
                        children: eventos.take(5).map((evento) {
                          return _EventoHomeCard(
                            titulo: evento.titulo,
                            desc: evento.descricao,
                            onTap: () => context.push('/eventos/${evento.id}'),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erro ao carregar agenda: $e')),
                  ),

                  const SizedBox(height: 32),
                  const Text('Mensagem do Dia', style: AppTextStyles.heading),
                  const SizedBox(height: 12),
                  _VersiculoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventoHomeCard extends StatelessWidget {
  final String titulo;
  final String desc;
  final VoidCallback onTap;

  const _EventoHomeCard({required this.titulo, required this.desc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.event_note, color: AppColors.primary),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _VersiculoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote, color: AppColors.primary, size: 32),
          const SizedBox(height: 12),
          const Text(
            '"Lâmpada para os meus pés é tua palavra, e luz para o meu caminho."',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text('Salmos 119:105', 
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
