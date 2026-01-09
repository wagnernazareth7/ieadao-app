import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/current_user_provider.dart';
import 'widgets/member_card_digital.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _picker = ImagePicker();
  bool _isUploading = false;

  /// ATUALIZAÇÃO SÉNIOR: Sincronização Total de Identidade
  Future<void> _updatePhoto(String uid) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 25, 
      maxWidth: 200,   
    );
    
    if (pickedFile == null) return;

    setState(() => _isUploading = true);
    
    try {
      final Uint8List bytes = await pickedFile.readAsBytes();
      final String base64Image = base64Encode(bytes);
      final String dataUri = 'data:image/jpeg;base64,$base64Image';

      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      // 1. Atualiza na conta do sistema (para o Cartão Digital do membro)
      batch.update(db.collection('users').doc(uid), {
        'photoUrl': dataUri,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Atualiza na ficha ministerial (para o Admin e outros membros verem na lista)
      // Usamos Set com merge para garantir que o documento 'membros' receba a foto mesmo se ainda não tiver outros dados
      batch.set(db.collection('membros').doc(uid), {
        'photoUrl': dataUri,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identidade visual sincronizada com a igreja!'), backgroundColor: Colors.green)
        );
        ref.invalidate(currentUserProvider);
      }
    } catch (e) {
      debugPrint('Erro na sincronização ministerial: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao atualizar foto.'), backgroundColor: Colors.redAccent)
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showEditDialog(String uid, String? currentPhone, String? currentAddress) {
    final phoneCtrl = TextEditingController(text: currentPhone ?? '');
    final addrCtrl = TextEditingController(text: currentAddress ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Editar Meus Dados', style: AppTextStyles.heading),
            const SizedBox(height: 20),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telemóvel', border: OutlineInputBorder(), prefixText: '+258 ')),
            const SizedBox(height: 16),
            TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Morada', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final db = FirebaseFirestore.instance;
                  final batch = db.batch();
                  
                  batch.update(db.collection('users').doc(uid), {
                    'phone': phoneCtrl.text.trim(),
                    'address': addrCtrl.text.trim(),
                  });
                  
                  batch.update(db.collection('membros').doc(uid), {
                    'phone': phoneCtrl.text.trim(),
                  });

                  await batch.commit();
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('GUARDAR ALTERAÇÕES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Minha Caminhada'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          userAsync.maybeWhen(
            data: (user) => user != null ? IconButton(
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: () => _showEditDialog(user.uid, user.phone, user.address),
            ) : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Utilizador não encontrado.'));

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      MemberCardDigital(
                        user: user,
                        onPhotoTap: () => _updatePhoto(user.uid),
                      ),
                      if (_isUploading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(24)),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: Colors.white),
                                  SizedBox(height: 12),
                                  Text('Sincronizando foto...', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('JORNADA ESPIRITUAL', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.2, fontSize: 11)),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                        child: Column(
                          children: [
                            _buildInfoTile(Icons.auto_awesome, 'FASE ATUAL', _formatStatus(user.spiritualStatus), color: Colors.orange),
                            const Divider(height: 1, indent: 50),
                            _buildInfoTile(Icons.water_drop, 'BATISMO', user.isBaptized ? 'Batizado nas Águas' : 'Não Batizado', color: Colors.cyan),
                            if (user.isBaptized && user.baptismDate != null && user.baptismDate!.isNotEmpty) ...[
                              const Divider(height: 1, indent: 50),
                              _buildInfoTile(Icons.calendar_month, 'DATA DO BATISMO', user.baptismDate!, color: Colors.blue),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Text('DADOS CADASTRAIS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.2, fontSize: 11)),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                        child: Column(
                          children: [
                            _buildInfoTile(Icons.email_outlined, 'E-MAIL', user.email),
                            const Divider(height: 1, indent: 50),
                            _buildInfoTile(Icons.phone_android, 'CONTACTO', user.phone != null && user.phone!.isNotEmpty ? '+258 ${user.phone}' : 'Clique em editar'),
                            const Divider(height: 1, indent: 50),
                            _buildInfoTile(Icons.home_outlined, 'MORADA', user.address != null && user.address!.isNotEmpty ? user.address! : 'Clique em editar'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  String _formatStatus(String? status) {
    switch (status) {
      case 'novo_convertido': return 'Novo Convertido';
      case 'em_discipulado': return 'Em Discipulado';
      default: return 'Membro Pleno';
    }
  }

  Widget _buildInfoTile(IconData icon, String label, String value, {Color? color}) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color ?? AppColors.primary, size: 18),
      title: Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
    );
  }
}
