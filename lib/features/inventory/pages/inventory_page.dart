import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/inventory_item_model.dart';
import '../services/inventory_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final _service = InventoryService();

  void _openScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String code = barcodes.first.rawValue ?? "";
                  if (code.startsWith('PATRIMONIO_')) {
                    Navigator.pop(context);
                    _showItemDetailsById(code.replaceAll('PATRIMONIO_', ''));
                  }
                }
              },
            ),
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ),
            const Center(
              child: Icon(Icons.qr_code_scanner, color: Colors.white54, size: 200),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetailsById(String id) {
    // Busca o item e abre o diálogo de detalhes (implementação simplificada para o exemplo)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item identificado: $id')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestão de Património'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _openScanner,
            tooltip: 'Escanear Bem',
          ),
        ],
      ),
      body: StreamBuilder<List<InventoryItem>>(
        stream: _service.watchInventory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();

          final items = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) => _InventoryCard(item: items[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, _service),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NOVO BEM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Nenhum bem registado no inventário.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, InventoryService service) {
    final nameCtrl = TextEditingController();
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
              const Text('Registar Novo Bem', style: AppTextStyles.heading),
              const SizedBox(height: 20),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome do Item (Ex: Teclado Yamaha)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                      items: ['Som', 'Instrumentos', 'Mobiliário', 'Informática'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => category = v!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<ItemStatus>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                      items: ItemStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
                      onChanged: (v) => status = v!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: valueCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor Estimatido (MZN)', border: OutlineInputBorder())),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty) return;
                    final item = InventoryItem(
                      id: '',
                      name: nameCtrl.text.trim(),
                      description: '',
                      category: category,
                      status: status,
                      purchaseValue: double.tryParse(valueCtrl.text) ?? 0,
                      purchaseDate: DateTime.now(),
                      responsibleUid: '',
                      createdAt: DateTime.now(),
                    );
                    await service.saveItem(item);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('REGISTAR NO PATRIMÓNIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(item.status).withOpacity(0.1),
          child: Icon(_getCategoryIcon(item.category), color: _getStatusColor(item.status), size: 20),
        ),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('${item.category} • ${item.purchaseValue.toStringAsFixed(2)} MZN', style: const TextStyle(fontSize: 11)),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('CÓDIGO DE IDENTIFICAÇÃO (QR)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                QrImageView(
                  data: 'PATRIMONIO_${item.id}',
                  version: QrVersions.auto,
                  size: 150.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 8),
                Text('ID: ${item.id}', style: const TextStyle(fontSize: 9, color: Colors.blueGrey)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuickAction(Icons.edit, 'EDITAR', () {}),
                    const SizedBox(width: 24),
                    _buildQuickAction(Icons.print, 'IMPRIMIR', () {}),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
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
