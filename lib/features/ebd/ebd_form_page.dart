import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/ebd_turma.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../membros/providers/membros_provider.dart';
import 'ebd_controller.dart';

class EBDFormPage extends ConsumerStatefulWidget {
  final EBDTurma? turma;

  const EBDFormPage({super.key, this.turma});

  @override
  ConsumerState<EBDFormPage> createState() => _EBDFormPageState();
}

class _EBDFormPageState extends ConsumerState<EBDFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _professorController;
  List<String> _alunosIds = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.turma?.nome ?? '');
    _professorController = TextEditingController(text: widget.turma?.professor ?? '');
    _alunosIds = widget.turma != null ? List.from(widget.turma!.alunosIds) : [];
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _professorController.dispose();
    super.dispose();
  }

  void _abrirSeletorDeAlunos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Consumer(
          builder: (context, ref, _) {
            final membrosAsync = ref.watch(todosMembrosProvider);
            return membrosAsync.when(
              data: (membros) => Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Selecionar Alunos', style: AppTextStyles.heading),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: membros.length,
                      itemBuilder: (context, index) {
                        final m = membros[index];
                        final selecionado = _alunosIds.contains(m.id);
                        return CheckboxListTile(
                          title: Text(m.nome),
                          subtitle: Text(m.role),
                          value: selecionado,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _alunosIds.add(m.id);
                              } else {
                                _alunosIds.remove(m.id);
                              }
                            });
                            Navigator.pop(context);
                            _abrirSeletorDeAlunos(); // Reabre para atualizar UI (hack simples)
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
            );
          },
        ),
      ),
    );
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final controller = ref.read(ebdControllerProvider);

    try {
      if (widget.turma == null) {
        await controller.criarTurma(
          nome: _nomeController.text.trim(),
          professor: _professorController.text.trim(),
        );
        // Nota: No criarTurma atual do controller, alunosIds começam vazios. 
        // Em apps reais, podes passar a lista aqui também.
      } else {
        final turmaAtualizada = EBDTurma(
          id: widget.turma!.id,
          nome: _nomeController.text.trim(),
          professor: _professorController.text.trim(),
          alunosIds: _alunosIds,
          ativa: widget.turma!.ativa,
        );
        await controller.editarTurma(turmaAtualizada);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados da turma salvos!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membrosAsync = ref.watch(todosMembrosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.turma == null ? 'Nova Turma' : 'Gerir Turma'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome da Turma', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _professorController,
                decoration: const InputDecoration(labelText: 'Nome do Professor', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Alunos Matriculados', style: AppTextStyles.heading),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('ADICIONAR'),
                    onPressed: _abrirSeletorDeAlunos,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Lista de alunos selecionados
              membrosAsync.when(
                data: (membros) {
                  final alunosDaTurma = membros.where((m) => _alunosIds.contains(m.id)).toList();
                  if (alunosDaTurma.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('Nenhum aluno adicionado.')),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alunosDaTurma.length,
                    itemBuilder: (context, index) {
                      final m = alunosDaTurma[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(m.firstName[0])),
                        title: Text(m.nome),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => setState(() => _alunosIds.remove(m.id)),
                        ),
                      );
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erro: $e'),
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _salvar,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SALVAR TURMA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
