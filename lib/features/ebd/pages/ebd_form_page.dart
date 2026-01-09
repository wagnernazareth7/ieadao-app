import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/ebd_class.dart';
import '../services/ebd_class_service.dart';
import '../../membros/providers/membro_providers.dart';
import '../../membros/models/membro.dart';

class EbdFormPage extends ConsumerStatefulWidget {
  final EbdClass? turma;
  const EbdFormPage({super.key, this.turma});

  @override
  ConsumerState<EbdFormPage> createState() => _EbdFormPageState();
}

class _EbdFormPageState extends ConsumerState<EbdFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _minAgeCtrl = TextEditingController(text: '0');
  final _maxAgeCtrl = TextEditingController(text: '99');
  
  List<String> _selectedProfessors = [];
  List<String> _selectedStudents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.turma != null) {
      _nameCtrl.text = widget.turma!.name;
      _descCtrl.text = widget.turma!.description;
      _minAgeCtrl.text = widget.turma!.minAge.toString();
      _maxAgeCtrl.text = widget.turma!.maxAge.toString();
      // CORREÇÃO: Usando teacherIds conforme o modelo real
      _selectedProfessors = List.from(widget.turma!.teacherIds);
      _selectedStudents = List.from(widget.turma!.studentIds);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final service = EbdClassService();

    final dadosTurma = EbdClass(
      id: widget.turma?.id ?? '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      minAge: int.tryParse(_minAgeCtrl.text) ?? 0,
      maxAge: int.tryParse(_maxAgeCtrl.text) ?? 99,
      teacherIds: _selectedProfessors, // CORREÇÃO: teacherIds
      studentIds: _selectedStudents,
    );

    try {
      if (widget.turma == null) {
        await service.createClass(dadosTurma);
      } else {
        await service.updateClass(widget.turma!.id, dadosTurma.toMap());
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuração pedagógica salva!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.turma == null ? 'Configurar Turma' : 'Gestão Pedagógica'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nome da Classe', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minAgeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Idade Mínima', border: OutlineInputBorder(), suffixText: 'anos'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _maxAgeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Idade Máxima', border: OutlineInputBorder(), suffixText: 'anos'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('O sistema sugerirá promoções quando os alunos saírem desta faixa.', style: TextStyle(fontSize: 10, color: Colors.grey)),

                  const SizedBox(height: 32),
                  const Text('PROFESSORES RESPONSÁVEIS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  membersAsync.when(
                    data: (members) => _buildMemberSelector(members, isProfessor: true),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Erro ao carregar'),
                  ),

                  const SizedBox(height: 32),
                  const Text('ALUNOS MATRICULADOS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  membersAsync.when(
                    data: (members) => _buildMemberSelector(members, isProfessor: false),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Erro ao carregar'),
                  ),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('GUARDAR CONFIGURAÇÃO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildMemberSelector(List<Membro> allMembers, {required bool isProfessor}) {
    final members = allMembers.where((m) => m.active).toList();
    final selectedList = isProfessor ? _selectedProfessors : _selectedStudents;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300), 
        borderRadius: BorderRadius.circular(12)
      ),
      child: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, i) {
          final m = members[i];
          final isSelected = selectedList.contains(m.id);
          return CheckboxListTile(
            dense: true,
            title: Text(m.nome, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            subtitle: Text(m.email, style: const TextStyle(fontSize: 10)),
            value: isSelected,
            activeColor: AppColors.secondary,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  selectedList.add(m.id);
                } else {
                  selectedList.remove(m.id);
                }
              });
            },
          );
        },
      ),
    );
  }
}
