// lib/features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../evento/evento_controller.dart';
import '../evento/evento_form_page.dart';
import '../../core/theme/app_colors.dart';

class HomePage extends ConsumerWidget { // Mudado para ConsumerWidget
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usando o provider de eventos que já criamos
    final eventosAsync = ref.watch(todosEventosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IEADAO - Home'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.push('/eventos'), // Navega para a lista completa
            tooltip: 'Lista de Eventos',
          ),
        ],
      ),
      body: eventosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (eventos) {
          if (eventos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhum evento para hoje.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/evento_form'),
                    child: const Text('Criar Primeiro Evento'),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(evento.titulo),
                  subtitle: Text(evento.descricao),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navega para os detalhes usando GoRouter
                    context.push('/eventos/${evento.id}');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/evento_form'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
