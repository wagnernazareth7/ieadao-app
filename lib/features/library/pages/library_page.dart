import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/library_service.dart';
import '../models/library_item_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/current_user_provider.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final _service = LibraryService();
  String _selectedCategory = 'Todos';
  final List<String> _categories = ['Todos', 'Estudos Bíblicos', 'EBD', 'Harpa', 'Manuais'];
  bool _isUploading = false;

  Future<void> _uploadFile(BuildContext context) async {
    // 1. Seleciona o ficheiro do dispositivo
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'mp3', 'mp4'],
    );

    if (result == null) return;

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Manuais';

    // 2. Diário de Detalhes
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Detalhes do Material'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título do Documento')),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descrição Breve')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  items: _categories.skip(1).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => category = v!,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty) return;
                Navigator.pop(context);
                _processUpload(result, titleCtrl.text, descCtrl.text, category);
              },
              child: const Text('SUBIR ARQUIVO'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processUpload(FilePickerResult result, String title, String desc, String cat) async {
    setState(() => _isUploading = true);
    try {
      final fileName = result.files.single.name;
      final storageRef = FirebaseStorage.instance.ref().child('library/$cat/$fileName');
      
      // Upload compatível com Web e Mobile
      if (kIsWeb) {
        await storageRef.putData(result.files.single.bytes!);
      } else {
        await storageRef.putFile(File(result.files.single.path!));
      }

      final url = await storageRef.getDownloadURL();

      // Grava na base de dados
      await FirebaseFirestore.instance.collection('library').add({
        'title': title,
        'description': desc,
        'category': cat,
        'fileUrl': url,
        'type': _detectType(fileName),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material adicionado ao acervo!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no upload: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _detectType(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) return 'pdf';
    if (fileName.toLowerCase().endsWith('.mp3')) return 'audio';
    if (fileName.toLowerCase().endsWith('.mp4')) return 'video';
    return 'pdf';
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final isAdmin = userAsync.value?.roles.contains('admin') ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Biblioteca Digital'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_isUploading) const LinearProgressIndicator(color: Colors.orangeAccent),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: AppColors.primary,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _selectedCategory == cat ? AppColors.primary : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<LibraryItem>>(
              stream: _service.watchLibrary(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Acervo vazio nesta categoria.'));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => _LibraryCard(item: snapshot.data![index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        onPressed: () => _uploadFile(context),
        label: const Text('ADICIONAR MATERIAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_to_photos, color: Colors.white),
        backgroundColor: AppColors.secondary,
      ) : null,
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final LibraryItem item;
  const _LibraryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(item.type).withOpacity(0.1),
          child: Icon(_getTypeIcon(item.type), color: _getTypeColor(item.type)),
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(item.description, maxLines: 2),
        trailing: const Icon(Icons.download_for_offline, color: Colors.grey),
        onTap: () async {
          final url = Uri.parse(item.fileUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }

  IconData _getTypeIcon(LibraryType type) {
    switch (type) {
      case LibraryType.pdf: return Icons.picture_as_pdf;
      case LibraryType.audio: return Icons.headphones;
      case LibraryType.video: return Icons.play_circle_fill;
      case LibraryType.link: return Icons.link;
    }
  }

  Color _getTypeColor(LibraryType type) {
    switch (type) {
      case LibraryType.pdf: return Colors.redAccent;
      case LibraryType.audio: return Colors.orange;
      case LibraryType.video: return Colors.blue;
      case LibraryType.link: return Colors.teal;
    }
  }
}
