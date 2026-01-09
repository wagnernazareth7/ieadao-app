import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../evento_controller.dart';
import '../evento_model.dart';

class EventoForm extends ConsumerStatefulWidget {
  final Evento? evento;

  const EventoForm({super.key, this.evento});

  @override
  ConsumerState<EventoForm> createState() => _EventoFormState();
}

class _EventoFormState extends ConsumerState<EventoForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titulo;
  late TextEditingController _descricao;

  @override
  void initState() {
    super.initState();
    _titulo = TextEditingController(text: widget.evento?.titulo ?? '');
    _descricao = TextEditingController(text: widget.evento?.descricao ?? '');
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // CORREÇÃO: Removido .notifier pois é um Provider simples
    final controller = ref.read(eventoControllerProvider);

    try {
      // CORREÇÃO: Usando o método unificado salvarEvento com o objeto completo
      final eventoParaSalvar = Evento(
        id: widget.evento?.id ?? '',
        titulo: _titulo.text.trim(),
        descricao: _descricao.text.trim(),
        local: widget.evento?.local ?? 'Igreja Sede',
        data: widget.evento?.data ?? DateTime.now(),
        categoria: widget.evento?.categoria ?? 'Culto',
      );

      await controller.salvarEvento(eventoParaSalvar);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento salvo com sucesso')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar evento: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titulo,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (v) =>
              v == null || v.isEmpty ? 'Informe o título' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descricao,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
              validator: (v) =>
              v == null || v.isEmpty ? 'Informe a descrição' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvar,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
