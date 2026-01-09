import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'evento_controller.dart';
import 'evento_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class EventoFormPage extends ConsumerStatefulWidget {
  final Evento? evento;

  const EventoFormPage({super.key, this.evento});

  @override
  ConsumerState<EventoFormPage> createState() => _EventoFormPageState();
}

class _EventoFormPageState extends ConsumerState<EventoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();
  final _localController = TextEditingController();
  
  DateTime _dataSelecionada = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _horaSelecionada = const TimeOfDay(hour: 18, minute: 0);
  String _categoria = 'Culto';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.evento != null) {
      _tituloController.text = widget.evento!.titulo;
      _descController.text = widget.evento!.descricao;
      _localController.text = widget.evento!.local;
      _dataSelecionada = widget.evento!.data;
      _horaSelecionada = TimeOfDay.fromDateTime(widget.evento!.data);
      _categoria = widget.evento!.categoria;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descController.dispose();
    _localController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (data != null) setState(() => _dataSelecionada = data);
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
    );
    if (hora != null) setState(() => _horaSelecionada = hora);
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final dataCompleta = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      _horaSelecionada.hour,
      _horaSelecionada.minute,
    );

    final novoEvento = Evento(
      id: widget.evento?.id ?? '',
      titulo: _tituloController.text.trim(),
      descricao: _descController.text.trim(),
      local: _localController.text.trim(),
      data: dataCompleta,
      categoria: _categoria,
    );

    try {
      await ref.read(eventoControllerProvider).salvarEvento(novoEvento);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento agendado com sucesso!'), backgroundColor: AppColors.secondary),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.evento == null ? 'Agendar Evento' : 'Editar Evento'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(labelText: 'Título do Evento', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Descrição / Detalhes', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _localController,
                    decoration: const InputDecoration(labelText: 'Localização', border: OutlineInputBorder(), hintText: 'Ex: Igreja Sede'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _categoria,
                    decoration: const InputDecoration(labelText: 'Tipo de Evento', border: OutlineInputBorder()),
                    items: ['Culto', 'Ensaio', 'Reunião', 'Festividade', 'Outro']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _categoria = v!),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text('${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}'),
                          onPressed: _selecionarData,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(_horaSelecionada.format(context)),
                          onPressed: _selecionarHora,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _salvar,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('SALVAR EVENTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
