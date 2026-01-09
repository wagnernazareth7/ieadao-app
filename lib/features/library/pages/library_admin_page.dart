import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/library_item_model.dart';
import '../services/library_service.dart';
import '../../../core/theme/app_colors.dart';

class LibraryAdminPage extends StatefulWidget {
  const LibraryAdminPage({super.key});

  @override
  State<LibraryAdminPage> createState() => _LibraryAdminPageState();
}

class _LibraryAdminPageState extends State<LibraryAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = LibraryService();
  
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  String _selectedCategory = 'Estudos Bíblicos';
  LibraryType _selectedType = LibraryType.pdf;
  File? _selectedFile;
  bool _isUploading = false;

  final List<String> _categories = ['Estudos Bíblicos', 'EBD', 'Harpa', 'Manuais'];

  Future<void> _pickFile() async {
    FileType pickType = FileType.any;
    if (_selectedType == LibraryType.pdf) pickType = FileType.custom;
    if (_selectedType == LibraryType.audio) pickType = FileType.audio;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: pickType,
      allowedExtensions: _selectedType == LibraryType.pdf ? ['pdf'] : null,
    );

    if (result != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um ficheiro e preencha o título.')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Upload para o Storage
      final ref = FirebaseStorage.instance.ref().child('library/${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.path.split('/').last}');
      await ref.putFile(_selectedFile!);
      final url = await ref.getDownloadURL();

      // 2. Salvar no Firestore
      final item = LibraryItem(
        id: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _selectedCategory,
        fileUrl: url,
        type: _selectedType,
        createdAt: DateTime.now(),
      );

      await _service.addItem(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material adicionado com sucesso!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Material'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: _isUploading 
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Enviando ficheiro...')]))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<LibraryType>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo de Conteúdo', border: OutlineInputBorder()),
                    items: LibraryType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                    onChanged: (v) => setState(() { _selectedType = v!; _selectedFile = null; }),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Título do Material', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Breve Descrição', border: OutlineInputBorder()), maxLines: 3),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: Text(_selectedFile == null ? 'Selecionar Ficheiro' : 'Alterar: ${_selectedFile!.path.split('/').last}'),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('GUARDAR NA BIBLIOTECA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
