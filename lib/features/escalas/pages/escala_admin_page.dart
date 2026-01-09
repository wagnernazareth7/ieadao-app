import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/escala_model.dart';
import '../services/escala_service.dart';

class EscalaAdminPage extends ConsumerStatefulWidget {
  const EscalaAdminPage({super.key});

  @override
  ConsumerState<EscalaAdminPage> createState() => _EscalaAdminPageState();
}

class _EscalaAdminPageState extends ConsumerState<EscalaAdminPage> {
  final _service = EscalaService();

  final List<String> _tiposCulto = [
    'Culto Público',
    'Culto de Intercessão',
    'Estudo Bíblico',
    'Santa Ceia',
    'Culto de Acção de Graça',
    'Culto de Encerramento da EBD',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestão de Escalas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Escala>>(
        stream: _service.watchUpcomingEscalas(), // CORREÇÃO: Usar o mesmo método do widget de home
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final escalas = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: escalas.length,
            itemBuilder: (context, index) {
              final e = escalas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(e.tipoCulto, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${DateFormat('dd/MM/yyyy').format(e.data)} • Dir: ${e.dirigente}'),
                  trailing: const Icon(Icons.edit_note, color: AppColors.primary),
                  onTap: () => _showEscalaDialog(context, e),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEscalaDialog(context),
        label: const Text('NOVA ESCALA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _showEscalaDialog(BuildContext context, [Escala? escala]) {
    final pregadorCtrl = TextEditingController(text: escala?.pregador);
    final dirigenteCtrl = TextEditingController(text: escala?.dirigente);
    final louvorCtrl = TextEditingController(text: escala?.louvor);
    final canticosCtrl = TextEditingController(text: escala?.canticos);
    final obsCtrl = TextEditingController(text: escala?.observacoes);
    String selectedTipo = escala?.tipoCulto ?? _tiposCulto.first;
    DateTime selectedDate = escala?.data ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Configurar Escala de Culto', style: AppTextStyles.heading),
                const SizedBox(height: 24),
                
                DropdownButtonFormField<String>(
                  value: selectedTipo,
                  decoration: const InputDecoration(labelText: 'Tipo de Culto', border: OutlineInputBorder()),
                  items: _tiposCulto.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDialogState(() => selectedTipo = v!),
                ),
                
                const SizedBox(height: 16),
                ListTile(
                  title: Text('Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
                    if (d != null) setDialogState(() => selectedDate = d);
                  },
                ),
                
                const SizedBox(height: 16),
                TextField(controller: dirigenteCtrl, decoration: const InputDecoration(labelText: 'Dirigente', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: pregadorCtrl, decoration: const InputDecoration(labelText: 'Pregador', border: OutlineInputBorder())),
                
                const Divider(height: 40),
                
                TextField(controller: louvorCtrl, decoration: const InputDecoration(labelText: 'Equipe de Louvor (Opcional)', border: OutlineInputBorder(), hintText: 'Pode ficar vazio')),
                const SizedBox(height: 16),
                TextField(controller: canticosCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Cânticos/Hinos (Opcional)', border: OutlineInputBorder(), hintText: 'Lista de hinos...')),
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final novaEscala = Escala(
                        id: escala?.id ?? '', // Se for nulo, id vai vazio para o saveEscala tratar como novo
                        data: selectedDate,
                        tipoCulto: selectedTipo,
                        pregador: pregadorCtrl.text.trim(),
                        dirigente: dirigenteCtrl.text.trim(),
                        louvor: louvorCtrl.text.trim().isEmpty ? null : louvorCtrl.text.trim(),
                        canticos: canticosCtrl.text.trim().isEmpty ? null : canticosCtrl.text.trim(),
                        observacoes: obsCtrl.text.trim(),
                      );
                      
                      // CORREÇÃO SÉNIOR: Chamada ao método unificado do serviço
                      await _service.saveEscala(novaEscala);
                      
                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('GUARDAR ESCALA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
