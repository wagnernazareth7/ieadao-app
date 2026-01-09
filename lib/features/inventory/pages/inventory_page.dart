import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inventory_item_model.dart';
import '../services/inventory_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = InventoryService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventário de Património'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<InventoryItem>>(
        stream: service.watchInventory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Nenhum bem registado.'));

          final items = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _InventoryCard(item: item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, service),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context, InventoryService service) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    String category = 'Som';
    ItemStatus status = ItemStatus.novo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Novo Bem Patrimonial', style: AppTextStyles.heading),
              const SizedBox(height: 20),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome do Item', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                      items: ['Som', 'Instrumentos', 'Mobiliário', 'Construção', 'Informática'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setDialogState(() => category = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<ItemStatus>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                      items: ItemStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
                      onChanged: (v) => setDialogState(() => status = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: valueCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor de Compra (MZN)', border: OutlineInputBorder())),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty) return;
                    final item = InventoryItem(
                      id: '',
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      category: category,
                      status: status,
                      purchaseValue: double.tryParse(valueCtrl.text) ?? 0,
                      purchaseDate: DateTime.now(),
                      responsibleUid: '',
                      createdAt: DateTime.now(),
                    );
                    await service.saveItem(item);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('REGISTAR BEM', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  const _InventoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(item.status).withOpacity(0.1),
          child: Icon(_getCategoryIcon(item.category), color: _getStatusColor(item.status), size: 20),
        ),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${item.category} • ${item.purchaseValue.toStringAsFixed(2)} MZN'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: _getStatusColor(item.status).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(item.status.name.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getStatusColor(item.status))),
        ),
      ),
    );
  }

  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.novo: return Colors.green;
      case ItemStatus.bom: return Colors.blue;
      case ItemStatus.regular: return Colors.orange;
      case ItemStatus.danificado:
      case ItemStatus.em_manutencao: return Colors.red;
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Som': return Icons.speaker;
      case 'Instrumentos': return Icons.music_note;
      case 'Mobiliário': return Icons.chair;
      case 'Informática': return Icons.computer;
      default: return Icons.inventory_2;
    }
  }
}
