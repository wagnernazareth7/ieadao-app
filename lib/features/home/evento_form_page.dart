import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class EventoFormPage extends StatefulWidget {
  final String? eventoId;
  const EventoFormPage({super.key, this.eventoId});

  @override
  State<EventoFormPage> createState() => _EventoFormPageState();
}

class _EventoFormPageState extends State<EventoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventoId != null) {
      FirebaseFirestore.instance
          .collection('eventos')
          .doc(widget.eventoId)
          .get()
          .then((doc) {
        if (mounted && doc.exists) { // Adicionado check de mounted
          final data = doc.data()!;
          _nomeController.text = data['nome'] ?? '';
          _descricaoController.text = data['descricao'] ?? '';
        }
      });
    }
  }

  Future<void> _saveEvento() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) setState(() => _loading = true);

    final data = {
      'nome': _nomeController.text,
      'descricao': _descricaoController.text,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      final collection = FirebaseFirestore.instance.collection('eventos');
      if (widget.eventoId != null) {
        await collection.doc(widget.eventoId).update(data);
      } else {
        await collection.add(data);
      }

      if (mounted) { // Usando mounted do State
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento salvo com sucesso!')) // Adicionado const
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) { // Usando mounted do State
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar evento: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventoId != null ? 'Editar Evento' : 'Novo Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _saveEvento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
