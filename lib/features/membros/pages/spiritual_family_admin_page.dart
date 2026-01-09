import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/membro_providers.dart';
import '../models/membro.dart';

class SpiritualFamilyAdminPage extends ConsumerStatefulWidget {
  const SpiritualFamilyAdminPage({super.key});

  @override
  ConsumerState<SpiritualFamilyAdminPage> createState() => _SpiritualFamilyAdminPageState();
}

class _SpiritualFamilyAdminPageState extends ConsumerState<SpiritualFamilyAdminPage> {
  Membro? _selectedParent;
  Membro? _selectedChild;

  Future<void> _linkFamily() async {
    if (_selectedParent == null || _selectedChild == null) return;
    if (_selectedParent!.id == _selectedChild!.id) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Um membro não pode ser pai de si mesmo.')));
      return;
    }

    try {
      final db = FirebaseFirestore.instance;
      
      // 1. Atualiza o Filho com o ID do Pai
      await db.collection('users').doc(_selectedChild!.id).update({
        'spiritualParentId': _selectedParent!.id,
      });

      // 2. Atualiza o Pai adicionando o Filho à lista
      await db.collection('users').doc(_selectedParent!.id).update({
        'spiritualChildrenIds': FieldValue.arrayUnion([_selectedChild!.id]),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vínculo Espiritual Criado! Amém.')));
        setState(() {
          _selectedParent = null;
          _selectedChild = null;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paternidade Espiritual'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FORMAR VÍNCULO DE DISCIPULADO', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            const Text('Selecione os membros para criar o elo de cuidado.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            
            const SizedBox(height: 32),

            // 1. SELEÇÃO DO PAI/MÃE
            _buildSelectionSection(
              title: 'PAI OU MÃE NA FÉ',
              selectedMember: _selectedParent,
              membersAsync: membersAsync,
              onSelected: (m) => setState(() => _selectedParent = m),
              color: Colors.blue,
            ),

            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Icon(Icons.link, color: Colors.grey),
            )),

            // 2. SELEÇÃO DO FILHO
            _buildSelectionSection(
              title: 'FILHO(A) NA FÉ',
              selectedMember: _selectedChild,
              membersAsync: membersAsync,
              onSelected: (m) => setState(() => _selectedChild = m),
              color: Colors.green,
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (_selectedParent != null && _selectedChild != null) ? _linkFamily : null,
                icon: const Icon(Icons.favorite, color: Colors.white),
                label: const Text('CONFIRMAR VÍNCULO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSection({
    required String title,
    Membro? selectedMember,
    required AsyncValue<List<Membro>> membersAsync,
    required Function(Membro) onSelected,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: membersAsync.when(
            data: (members) => DropdownButtonHideUnderline(
              child: DropdownButton<Membro>(
                isExpanded: true,
                value: selectedMember,
                hint: const Text('Selecione o membro...', style: TextStyle(fontSize: 14)),
                items: members.where((m) => m.active).map((m) => DropdownMenuItem(
                  value: m,
                  child: Text('${m.firstName} ${m.lastName}', style: const TextStyle(fontSize: 14)),
                )).toList(),
                onChanged: (val) => onSelected(val!),
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Erro ao carregar'),
          ),
        ),
      ],
    );
  }
}
