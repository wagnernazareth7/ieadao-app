import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ieadao/core/theme/app_colors.dart';
import 'package:ieadao/core/theme/app_text_styles.dart';
import '../models/setlist_model.dart';
import '../services/setlist_service.dart';
import '../../../core/models/music_model.dart';
import '../../coral/services/coral_service.dart';

class SetlistEditorPage extends ConsumerStatefulWidget {
  final String? setlistId;
  const SetlistEditorPage({super.key, this.setlistId});

  @override
  ConsumerState<SetlistEditorPage> createState() => _SetlistEditorPageState();
}

class _SetlistEditorPageState extends ConsumerState<SetlistEditorPage> {
  final _setlistService = SetlistService();
  DateTime _selectedDate = DateTime.now();
  List<SetlistItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.setlistId != null) {
      _loadExistingSetlist();
    }
  }

  void _loadExistingSetlist() {
    _setlistService.watchSetlistById(widget.setlistId!).listen((setlist) {
      if (setlist != null && mounted) {
        setState(() {
          _selectedDate = setlist.date;
          _items = setlist.items;
        });
      }
    });
  }

  Future<void> _saveSetlist() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicione pelo menos uma música!')));
      return;
    }
    setState(() => _isLoading = true);
    final setlist = Setlist(
      id: widget.setlistId ?? '',
      date: _selectedDate,
      items: _items,
      ministeringLeader: 'Líder de Louvor',
    );
    await _setlistService.saveSetlist(setlist);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setlist Ministerial Salva!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
    setState(() => _isLoading = false);
  }

  void _addMusicToSetlist(Music music) {
    setState(() {
      _items.add(SetlistItem(
        musicId: music.id,
        musicTitle: music.title,
        order: _items.length,
        notes: 'Tom: ', // Inicializa com espaço para o tom
      ));
    });
  }

  void _editItemNotes(int index) {
    final ctrl = TextEditingController(text: _items[index].notes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Instruções: ${_items[index].musicTitle}'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Ex: Tom G, Início suave, Transição suave...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _items[index] = SetlistItem(
                  musicId: _items[index].musicId,
                  musicTitle: _items[index].musicTitle,
                  order: _items[index].order,
                  notes: ctrl.text.trim(),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Montar Setlist do Culto'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading) 
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          else
            IconButton(icon: const Icon(Icons.check_circle_outline), onPressed: _saveSetlist, tooltip: 'Finalizar Setlist'),
        ],
      ),
      body: Row(
        children: [
          // ESQUERDA: REPERTÓRIO
          Expanded(
            flex: 2,
            child: _buildRepertoireList(),
          ),
          const VerticalDivider(width: 1, color: Colors.black12),
          // DIREITA: A PLAYLIST DO CULTO
          Expanded(
            flex: 3,
            child: _buildSetlistCanvas(),
          ),
        ],
      ),
    );
  }

  Widget _buildRepertoireList() {
    final coralService = CoralService();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: const Row(
            children: [
              Icon(Icons.library_music, size: 16, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text('REPERTÓRIO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Music>>(
            stream: coralService.watchRepertoire(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final musicas = snapshot.data!;
              return ListView.builder(
                itemCount: musicas.length,
                itemBuilder: (context, i) => ListTile(
                  dense: true,
                  title: Text(musicas[i].title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(musicas[i].composer, style: const TextStyle(fontSize: 10)),
                  trailing: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 20),
                  onTap: () => _addMusicToSetlist(musicas[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSetlistCanvas() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black12)),
            child: ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.purple),
              title: Text('Culto de ${DateFormat('dd/MM/yyyy').format(_selectedDate)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              trailing: const Icon(Icons.edit, size: 16),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
                if (d != null) setState(() => _selectedDate = d);
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _items.isEmpty 
              ? const Center(child: Text('Arraste ou clique para adicionar músicas.', style: TextStyle(color: Colors.grey, fontSize: 12)))
              : ReorderableListView.builder(
                  itemCount: _items.length,
                  onReorder: (oldIdx, newIdx) {
                    setState(() {
                      if (newIdx > oldIdx) newIdx -= 1;
                      final item = _items.removeAt(oldIdx);
                      _items.insert(newIdx, item);
                    });
                  },
                  itemBuilder: (context, i) => Card(
                    key: ValueKey('${_items[i].musicId}_$i'),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(radius: 12, backgroundColor: Colors.purple.withOpacity(0.1), child: Text('${i+1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple))),
                      title: Text(_items[i].musicTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(_items[i].notes ?? 'Toque para adicionar notas (Tom, Início...)', 
                        style: TextStyle(fontSize: 11, color: _items[i].notes == null || _items[i].notes!.isEmpty ? Colors.grey : Colors.blueGrey, fontStyle: FontStyle.italic)),
                      trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20), onPressed: () => setState(() => _items.removeAt(i))),
                      onTap: () => _editItemNotes(i),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
