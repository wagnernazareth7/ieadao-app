import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_of_service_model.dart';
import '../services/liturgia_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OrderOfServicePage extends StatefulWidget {
  const OrderOfServicePage({super.key});

  @override
  State<OrderOfServicePage> createState() => _OrderOfServicePageState();
}

class _OrderOfServicePageState extends State<OrderOfServicePage> {
  final _service = LiturgiaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Roteiros de Culto'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<OrderOfService>>(
        stream: _service.watchTodayServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return _buildNoActiveService();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceSection(service);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewServiceDialog(context),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildServiceSection(OrderOfService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: Text(service.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              onPressed: () => _service.deleteService(service.id),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...service.items.asMap().entries.map((entry) {
          return _buildStepCard(service, entry.key, entry.value);
        }).toList(),
        
        Center(
          child: TextButton.icon(
            onPressed: () => _showAddItemDialog(context, service),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('ADICIONAR ETAPA AO CULTO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStepCard(OrderOfService service, int index, OrderOfServiceItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: item.isCompleted ? 0 : 1,
      color: item.isCompleted ? Colors.green.withOpacity(0.05) : Colors.white,
      child: ListTile(
        dense: true,
        onTap: () => _service.toggleItem(service.id, List.from(service.items), index),
        leading: Icon(
          item.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: item.isCompleted ? Colors.green : Colors.grey,
          size: 20,
        ),
        title: Text(
          item.label, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 14,
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted ? Colors.grey : Colors.black87
          )
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.isCompleted && item.completedAt != null)
              Text(DateFormat('HH:mm').format(item.completedAt!), style: const TextStyle(fontSize: 9, color: Colors.grey)),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.blueGrey),
              onPressed: () => _showEditItemDialog(context, service, index, item),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewServiceDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Culto'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Ex: Culto de Jovens, Santa Ceia...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isEmpty) return;
              _service.startNewService(ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('INICIAR'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, OrderOfService service) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Etapa'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Nome da etapa...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isEmpty) return;
              final newItems = List<OrderOfServiceItem>.from(service.items);
              newItems.add(OrderOfServiceItem(label: ctrl.text.trim()));
              _service.updateFullService(OrderOfService(id: service.id, title: service.title, date: service.date, items: newItems));
              Navigator.pop(context);
            },
            child: const Text('ADICIONAR'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, OrderOfService service, int index, OrderOfServiceItem item) {
    final ctrl = TextEditingController(text: item.label);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Etapa'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              final newItems = List<OrderOfServiceItem>.from(service.items);
              newItems[index] = OrderOfServiceItem(label: ctrl.text.trim(), isCompleted: item.isCompleted, completedAt: item.completedAt);
              _service.updateFullService(OrderOfService(id: service.id, title: service.title, date: service.date, items: newItems));
              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveService() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Nenhum culto iniciado hoje.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showNewServiceDialog(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('INICIAR NOVO ROTEIRO', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
