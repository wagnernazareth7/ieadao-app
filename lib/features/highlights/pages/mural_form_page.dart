import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // IMPORTAÇÃO CORRIGIDA
import 'dart:io';
import '../models/culto_highlight_model.dart';
import '../services/culto_highlight_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MuralFormPage extends ConsumerStatefulWidget {
  final CultoHighlight? highlight;
  const MuralFormPage({super.key, this.highlight});

  @override
  ConsumerState<MuralFormPage> createState() => _MuralFormPageState();
}

class _MuralFormPageState extends ConsumerState<MuralFormPage> {
  final _service = CultoHighlightService();
  final _titleCtrl = TextEditingController();
  final _preacherCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  File? _preachingPhoto;
  final List<File> _galleryPhotos = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.highlight != null) {
      _titleCtrl.text = widget.highlight!.content['palavra']['titulo'] ?? '';
      _preacherCtrl.text = widget.highlight!.content['palavra']['pregador'] ?? '';
      _descCtrl.text = widget.highlight!.content['palavra']['descricao'] ?? '';
    }
  }

  Future<void> _pickImage(bool isHero) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() {
        if (isHero) {
          _preachingPhoto = File(picked.path);
        } else {
          _galleryPhotos.add(File(picked.path));
        }
      });
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      String? heroUrl;
      if (_preachingPhoto != null) {
        heroUrl = await _service.uploadFile(_preachingPhoto!, 'palavra', 'hero_${DateTime.now().millisecondsSinceEpoch}.jpg');
      }

      final List<String> galleryUrls = [];
      for (var f in _galleryPhotos) {
        final url = await _service.uploadFile(f, 'louvor', 'img_${DateTime.now().millisecondsSinceEpoch}.jpg');
        galleryUrls.add(url);
      }

      final highlight = CultoHighlight(
        id: widget.highlight?.id ?? '',
        data: DateTime.now(),
        domingoDoMes: 'Domingo de Adoração',
        content: {
          'palavra': {
            'titulo': _titleCtrl.text.trim(),
            'pregador': _preacherCtrl.text.trim(),
            'descricao': _descCtrl.text.trim(),
            'foto_preg': heroUrl ?? widget.highlight?.content['palavra']['foto_preg'],
          },
          'louvor': {
            'fotos': galleryUrls,
          }
        },
        createdAt: DateTime.now(),
      );

      await _service.publishHighlight(highlight);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mural publicado com sucesso!'), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Novo Destaque de Culto'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MOMENTO DA PALAVRA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Tema da Mensagem')),
            const SizedBox(height: 12),
            TextField(controller: _preacherCtrl, decoration: const InputDecoration(labelText: 'Nome do Pregador')),
            const SizedBox(height: 12),
            TextField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Resumo/Esboço da Palavra')),
            const SizedBox(height: 20),
            
            _buildPhotoPicker('Foto da Ministração', _preachingPhoto, () => _pickImage(true)),
            
            const SizedBox(height: 32),
            const Text('GALERIA DO LOUVOR (MULTIMÉDIA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._galleryPhotos.map((f) => ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(f, width: 80, height: 80, fit: BoxFit.cover))),
                InkWell(
                  onTap: () => _pickImage(false),
                  child: Container(
                    width: 80, 
                    height: 80, 
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
                    child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('PUBLICAR NO MURAL DA IGREJA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPicker(String label, File? file, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: file != null 
              ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(file, fit: BoxFit.cover)) 
              : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_enhance_outlined, size: 40, color: Colors.grey), SizedBox(height: 8), Text('Toque para selecionar foto', style: TextStyle(color: Colors.grey, fontSize: 12))]),
          ),
        ),
      ],
    );
  }
}
