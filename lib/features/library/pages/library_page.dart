import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/library_service.dart';
import '../models/library_item_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final _service = LibraryService();
  String _selectedCategory = 'Todos';
  final List<String> _categories = ['Todos', 'Estudos Bíblicos', 'EBD', 'Harpa', 'Manuais'];

  @override
  Widget build(BuildContext context) {
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
          // 1. Filtro de Categorias
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

          // 2. Lista de Recursos
          Expanded(
            child: StreamBuilder<List<LibraryItem>>(
              stream: _service.watchLibrary(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum material encontrado nesta categoria.'));
                }

                final items = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _LibraryCard(item: item);
                  },
                );
              },
            ),
          ),
        ],
      ),
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
        subtitle: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
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
