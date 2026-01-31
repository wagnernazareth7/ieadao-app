import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/visit_request_model.dart';
import '../services/visit_service.dart';
import '../providers/visit_providers.dart';
import '../../auth/providers/current_user_provider.dart';
import '../../../core/providers/service_providers.dart'; // CORREÇÃO: Importação do provider central
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class VisitRequestPage extends ConsumerStatefulWidget {
  const VisitRequestPage({super.key});

  @override
  ConsumerState<VisitRequestPage> createState() => _VisitRequestPageState();
}

class _VisitRequestPageState extends ConsumerState<VisitRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  VisitType _selectedType = VisitType.oracao;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    final request = VisitRequest(
      id: '',
      userId: user.uid,
      userName: "${user.firstName} ${user.lastName}",
      userPhone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      type: _selectedType,
      observation: _obsCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      // ✅ Agora o visitServiceProvider é reconhecido
      await ref.read(visitServiceProvider).submitRequest(request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação enviada com sucesso! Em breve entraremos em contato.'), backgroundColor: Colors.green)
        );
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
    final myVisitsAsync = ref.watch(myVisitsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Solicitar Visita'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFormHeader(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TIPO DE APOIO', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    _buildTypeSelector(),
                    
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Telefone para Contato', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(labelText: 'Endereço para a Visita', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _obsCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Observações ou Pedido Específico', border: OutlineInputBorder(), alignLabelWithHint: true),
                    ),
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('ENVIAR SOLICITAÇÃO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 48),
                    const Text('MEUS PEDIDOS RECENTES', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    myVisitsAsync.when(
                      data: (visits) => Column(
                        children: visits.map((v) => _buildRequestListItem(v)).toList(),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Erro ao carregar histórico'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(32))),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Como podemos cuidar de si?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('A nossa equipa ministerial está pronta para o apoiar.', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      children: VisitType.values.map((type) {
        final isSelected = _selectedType == type;
        return ChoiceChip(
          label: Text(type.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
          selected: isSelected,
          selectedColor: AppColors.secondary,
          onSelected: (val) => setState(() => _selectedType = type),
        );
      }).toList(),
    );
  }

  Widget _buildRequestListItem(VisitRequest v) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        title: Text(v.type.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(v.createdAt), style: const TextStyle(fontSize: 10)),
        trailing: _buildStatusBadge(v.status),
      ),
    );
  }

  Widget _buildStatusBadge(VisitStatus status) {
    Color color = Colors.grey;
    if (status == VisitStatus.agendada) color = Colors.blue;
    if (status == VisitStatus.concluida) color = Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }
}
