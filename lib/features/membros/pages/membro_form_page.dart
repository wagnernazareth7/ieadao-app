import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ieadao/core/constants/app_roles.dart';
import '../models/membro.dart';
import '../../../core/theme/app_colors.dart';

class MembroFormPage extends ConsumerStatefulWidget {
  final Membro? membro;
  const MembroFormPage({super.key, this.membro});

  @override
  ConsumerState<MembroFormPage> createState() => _MembroFormPageState();
}

class _MembroFormPageState extends ConsumerState<MembroFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _baptismDateController = TextEditingController();
  
  String _gender = 'Masculino';
  String _spiritualStatus = 'membro_pleno';
  List<String> _selectedRoles = [AppRoles.member];
  bool _active = true;
  bool _isBaptized = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.membro != null) {
      _firstNameController.text = widget.membro!.firstName;
      _lastNameController.text = widget.membro!.lastName;
      _emailController.text = widget.membro!.email;
      _phoneController.text = widget.membro!.phone;
      _birthDateController.text = widget.membro!.birthDate;
      _baptismDateController.text = widget.membro!.baptismDate;
      _gender = widget.membro!.gender;
      _active = widget.membro!.active;
      _isBaptized = widget.membro!.isBaptized;
      _spiritualStatus = widget.membro!.spiritualStatus;
      _selectedRoles = List.from(widget.membro!.roles);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    
    final db = FirebaseFirestore.instance;
    final String uid = widget.membro!.id; // UID do membro sendo editado

    final Map<String, dynamic> data = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'birthDate': _birthDateController.text.trim(),
      'baptismDate': _baptismDateController.text.trim(),
      'isBaptized': _isBaptized,
      'spiritualStatus': _spiritualStatus,
      'gender': _gender,
      'roles': _selectedRoles,
      'role': _selectedRoles.first,
      'active': _active,
      'photoUrl': widget.membro?.photoUrl, // Preserva a foto se houver
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      final batch = db.batch();
      
      // ATUALIZAÇÃO SÉNIOR: Garante que ambos os lados da base de dados fiquem iguais
      batch.set(db.collection('membros').doc(uid), data, SetOptions(merge: true));
      
      batch.set(db.collection('users').doc(uid), {
        'roles': _selectedRoles,
        'role': _selectedRoles.first,
        'active': _active,
        'gender': _gender,
        'birthDate': data['birthDate'],
        'isBaptized': _isBaptized,
        'baptismDate': data['baptismDate'],
        'spiritualStatus': _spiritualStatus,
        'photoUrl': widget.membro?.photoUrl, // Sincroniza a foto também
      }, SetOptions(merge: true));

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sincronização ministerial realizada!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? profileImage;
    if (widget.membro?.photoUrl != null && widget.membro!.photoUrl!.startsWith('data:image')) {
      try {
        profileImage = MemoryImage(base64Decode(widget.membro!.photoUrl!.split(',').last));
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.membro == null ? 'Novo Membro' : 'Editar Membro'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // VISUALIZAÇÃO DA FOTO NO ADMIN
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: profileImage,
                    child: profileImage == null ? const Icon(Icons.person, size: 40, color: AppColors.primary) : null,
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('IDENTIFICAÇÃO PESSOAL'),
                  const SizedBox(height: 16),
                  _buildTextField(_firstNameController, 'Nome Próprio', Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField(_lastNameController, 'Apelido', Icons.badge),
                  const SizedBox(height: 12),
                  _buildGenderAndBirth(),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('ACOMPANHAMENTO ESPIRITUAL'),
                  const SizedBox(height: 12),
                  _buildSpiritualSection(),

                  const SizedBox(height: 32),
                  _buildSectionHeader('MINISTÉRIOS E CARGOS'),
                  const SizedBox(height: 16),
                  _buildRolesWrap(),

                  const SizedBox(height: 32),
                  _buildSectionHeader('CONTACTO E ESTADO'),
                  const SizedBox(height: 12),
                  _buildTextField(_emailController, 'E-mail', Icons.email),
                  const SizedBox(height: 12),
                  _buildTextField(_phoneController, 'Telemóvel', Icons.phone, prefixText: '+258 '),
                  
                  SwitchListTile(
                    title: const Text('Membro Ativo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    value: _active,
                    activeColor: AppColors.secondary,
                    onChanged: (v) => setState(() => _active = v),
                  ),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _salvar,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('GUARDAR E SINCRONIZAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSpiritualSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _spiritualStatus,
            decoration: const InputDecoration(labelText: 'Fase do Irmão', border: InputBorder.none, prefixIcon: Icon(Icons.auto_awesome)),
            items: const [
              DropdownMenuItem(value: 'novo_convertido', child: Text('Novo Convertido')),
              DropdownMenuItem(value: 'em_discipulado', child: Text('Em Discipulado')),
              DropdownMenuItem(value: 'membro_pleno', child: Text('Membro Pleno')),
            ],
            onChanged: (val) => setState(() => _spiritualStatus = val!),
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Batizado nas Águas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            value: _isBaptized,
            activeColor: AppColors.secondary,
            onChanged: (v) => setState(() => _isBaptized = v),
          ),
          if (_isBaptized)
            TextFormField(
              controller: _baptismDateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Data do Batismo', border: InputBorder.none, prefixIcon: Icon(Icons.calendar_month)),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1940), lastDate: DateTime.now());
                if (d != null) setState(() => _baptismDateController.text = "${d.day}/${d.month}/${d.year}");
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRolesWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppRoles.all.map((role) {
        final isSelected = _selectedRoles.contains(role);
        return FilterChip(
          label: Text(AppRoles.getName(role), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedRoles.add(role);
              } else {
                if (_selectedRoles.length > 1) _selectedRoles.remove(role);
              }
            });
          },
          selectedColor: AppColors.primary,
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.2)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {String? prefixText}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        prefixText: prefixText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
    );
  }

  Widget _buildGenderAndBirth() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Género', border: OutlineInputBorder()),
            items: ['Masculino', 'Feminino'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => setState(() => _gender = v!),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _birthDateController,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Nascimento', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now().subtract(const Duration(days: 365*20)), firstDate: DateTime(1940), lastDate: DateTime.now());
              if (d != null) setState(() => _birthDateController.text = "${d.day}/${d.month}/${d.year}");
            },
          ),
        ),
      ],
    );
  }
}
