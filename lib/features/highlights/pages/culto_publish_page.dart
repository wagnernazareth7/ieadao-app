import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/culto_highlight_model.dart';
import '../services/culto_highlight_service.dart';
import '../../../core/theme/app_colors.dart';

class CultoPublishPage extends ConsumerStatefulWidget {
  const CultoPublishPage({super.key});

  @override
  ConsumerState<CultoPublishPage> createState() => _CultoPublishPageState();
}

class _CultoPublishPageState extends ConsumerState<CultoPublishPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = CultoHighlightService();
  final _picker = ImagePicker();

  bool _isPublishing = false;
  DateTime _dataCulto = DateTime.now();
  String _domingoDoMes = '1º Domingo';

  // --- CONTROLLERS PARA TÍTULOS EDITÁVEIS ---
  final _titleAbertura = TextEditingController(text: 'Abertura Oficial');
  final _titleLouvor = TextEditingController(text: 'Louvor e Acções de Graça');
  final _titlePalavra = TextEditingController(text: 'Momento da Palavra');
  final _titleAnuncios = TextEditingController(text: 'Anúncios da Igreja');
  final _titleOferta = TextEditingController(text: 'Momento da Oferta');
  final _titleMembros = TextEditingController(text: 'Participação dos Membros');

  // --- CAMPOS DE TEXTO ---
  final _descAbertura = TextEditingController();
  final _abertoPor = TextEditingController();
  final _passagemLida = TextEditingController();
  final _descPalavra = TextEditingController();
  final _pregadorCtrl = TextEditingController();
  final _tradutorCtrl = TextEditingController();
  final _descAnunciosPrinc = TextEditingController();
  final _descAnunciosCompl = TextEditingController();
  final _descOferta = TextEditingController();
  final _nomesMembros = TextEditingController();
  final List<TextEditingController> _louvaramCtrls = List.generate(5, (_) => TextEditingController());

  // --- MEDIA FILES ---
  File? _fotoPregador, _fotoTradutor, _videoEntrada, _audioPregacao, _videoLouvor;
  File? _fotoAnuncioPrinc, _videoAnuncioPrinc, _videoOferta;
  final List<File> _fotosLouvor = [];
  final List<File> _fotosAnunciosCompl = [];
  final List<File> _fotosMembros = [];

  @override
  void dispose() {
    _titleAbertura.dispose(); _titleLouvor.dispose(); _titlePalavra.dispose();
    _titleAnuncios.dispose(); _titleOferta.dispose(); _titleMembros.dispose();
    _descAbertura.dispose(); _abertoPor.dispose(); _passagemLida.dispose();
    _descPalavra.dispose(); _pregadorCtrl.dispose(); _tradutorCtrl.dispose();
    _descAnunciosPrinc.dispose(); _descAnunciosCompl.dispose(); _descOferta.dispose();
    _nomesMembros.dispose();
    for (var c in _louvaramCtrls) {c.dispose();}
    super.dispose();
  }

  Future<void> _pickMedia(String type, {int? slot, bool multiple = false}) async {
    if (type == 'image') {
      if (multiple) {
        final List<XFile> picked = await _picker.pickMultiImage();
        if (picked.isNotEmpty) {
          setState(() {
            if (slot == 1) _fotosLouvor.addAll(picked.map((x) => File(x.path)));
            if (slot == 2) _fotosAnunciosCompl.addAll(picked.map((x) => File(x.path)));
            if (slot == 3) _fotosMembros.addAll(picked.map((x) => File(x.path)));
          });
        }
      } else {
        final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          setState(() {
            if (slot == 1) _fotoPregador = File(picked.path);
            if (slot == 2) _fotoTradutor = File(picked.path);
            if (slot == 3) _fotoAnuncioPrinc = File(picked.path);
          });
        }
      }
    } else if (type == 'video') {
      final XFile? picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          if (slot == 1) _videoEntrada = File(picked.path);
          if (slot == 2) _videoLouvor = File(picked.path);
          if (slot == 3) _videoAnuncioPrinc = File(picked.path);
          if (slot == 4) _videoOferta = File(picked.path);
        });
      }
    } else if (type == 'audio') {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null) setState(() => _audioPregacao = File(result.files.single.path!));
    }
  }

  Future<void> _publicarFicha() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPublishing = true);

    try {
      final ts = DateTime.now().millisecondsSinceEpoch;

      // UPLOAD LOGIC
      String? urlPregador, urlTradutor, urlVidEntrada, urlAudio, urlVidLouvor, urlFotoAnPrinc, urlVidAnPrinc, urlVidOferta;
      if (_fotoPregador != null) urlPregador = await _service.uploadFile(_fotoPregador!, 'palavra', '${ts}_preg.jpg');
      if (_fotoTradutor != null) urlTradutor = await _service.uploadFile(_fotoTradutor!, 'palavra', '${ts}_trad.jpg');
      if (_videoEntrada != null) urlVidEntrada = await _service.uploadFile(_videoEntrada!, 'palavra', '${ts}_ent.mp4');
      if (_audioPregacao != null) urlAudio = await _service.uploadFile(_audioPregacao!, 'audios', '${ts}_prega.mp3');
      if (_videoLouvor != null) urlVidLouvor = await _service.uploadFile(_videoLouvor!, 'louvor', '${ts}_louvor.mp4');
      if (_fotoAnuncioPrinc != null) urlFotoAnPrinc = await _service.uploadFile(_fotoAnuncioPrinc!, 'anuncios', '${ts}_an_p.jpg');
      if (_videoAnuncioPrinc != null) urlVidAnPrinc = await _service.uploadFile(_videoAnuncioPrinc!, 'anuncios', '${ts}_an_v.mp4');
      if (_videoOferta != null) urlVidOferta = await _service.uploadFile(_videoOferta!, 'oferta', '${ts}_oferta.mp4');

      List<String> urlsFLouvor = [];
      for (var f in _fotosLouvor) { urlsFLouvor.add(await _service.uploadFile(f, 'louvor', '${ts}_${f.hashCode}.jpg')); }

      List<String> urlsFAnCompl = [];
      for (var f in _fotosAnunciosCompl) { urlsFAnCompl.add(await _service.uploadFile(f, 'anuncios', '${ts}_${f.hashCode}.jpg')); }

      List<String> urlsFMembros = [];
      for (var f in _fotosMembros) { urlsFMembros.add(await _service.uploadFile(f, 'membros', '${ts}_${f.hashCode}.jpg')); }

      final content = {
        'abertura': {'titulo': _titleAbertura.text, 'desc': _descAbertura.text, 'responsavel': _abertoPor.text, 'passagem': _passagemLida.text},
        'louvor': {'titulo': _titleLouvor.text, 'participantes': _louvaramCtrls.map((c) => c.text).where((t) => t.isNotEmpty).toList(), 'video': urlVidLouvor, 'fotos': urlsFLouvor},
        'palavra': {'titulo': _titlePalavra.text, 'pregador': _pregadorCtrl.text, 'tradutor': _tradutorCtrl.text, 'foto_preg': urlPregador, 'foto_trad': urlTradutor, 'vid_entrada': urlVidEntrada, 'audio': urlAudio},
        'anuncios': {'titulo': _titleAnuncios.text, 'princ_desc': _descAnunciosPrinc.text, 'princ_foto': urlFotoAnPrinc, 'princ_vid': urlVidAnPrinc, 'compl_desc': _descAnunciosCompl.text, 'compl_fotos': urlsFAnCompl},
        'oferta': {'titulo': _titleOferta.text, 'desc': _descOferta.text, 'video': urlVidOferta},
        'membros': {'titulo': _titleMembros.text, 'lista_nomes': _nomesMembros.text, 'fotos': urlsFMembros}
      };

      final highlight = CultoHighlight(id: '', data: _dataCulto, domingoDoMes: _domingoDoMes, content: content, createdAt: DateTime.now());
      await _service.publishHighlight(highlight);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ficha de Culto Digital publicada com sucesso!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ficha de Culto Digital'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: _isPublishing
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Enviando ficheiros e dados...')]))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeaderSection(),
              const Divider(height: 40),

              _buildExpandableSection(titleCtrl: _titleAbertura, icon: Icons.auto_stories, children: [
                _buildTextField(_descAbertura, 'Descrição da Abertura', maxLines: 3),
                _buildTextField(_abertoPor, 'Responsável pela Abertura'),
                _buildTextField(_passagemLida, 'Passagem Bíblica Lida'),
              ]),

              _buildExpandableSection(titleCtrl: _titleLouvor, icon: Icons.music_note, children: [
                const Text('Participantes:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ...List.generate(3, (i) => _buildTextField(_louvaramCtrls[i], 'Nome do Irmão ${i+1}')),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  _MediaButton(label: 'Fotos', icon: Icons.add_a_photo, file: _fotosLouvor.isNotEmpty ? _fotosLouvor.first : null, onTap: () => _pickMedia('image', slot: 1, multiple: true)),
                  _MediaButton(label: 'Vídeo', icon: Icons.videocam, file: _videoLouvor, onTap: () => _pickMedia('video', slot: 2)),
                ]),
              ]),

              _buildExpandableSection(titleCtrl: _titlePalavra, icon: Icons.menu_book, children: [
                _buildTextField(_descPalavra, 'Resumo da Ministração', maxLines: 4),
                _buildTextField(_pregadorCtrl, 'Pregador'),
                _buildTextField(_tradutorCtrl, 'Tradutor'),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  _MediaButton(label: 'Foto Pregador', icon: Icons.person, file: _fotoPregador, onTap: () => _pickMedia('image', slot: 1)),
                  _MediaButton(label: 'Foto Tradutor', icon: Icons.person_outline, file: _fotoTradutor, onTap: () => _pickMedia('image', slot: 2)),
                  _MediaButton(label: 'Vídeo Entrada', icon: Icons.videocam, file: _videoEntrada, onTap: () => _pickMedia('video', slot: 1)),
                  _MediaButton(label: 'Áudio Pregação', icon: Icons.mic, file: _audioPregacao, onTap: () => _pickMedia('audio')),
                ]),
              ]),

              _buildExpandableSection(titleCtrl: _titleAnuncios, icon: Icons.campaign, children: [
                const Text('Anúncios Principais:', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildTextField(_descAnunciosPrinc, 'Texto Anúncios Principais', maxLines: 2),
                Wrap(spacing: 8, children: [
                  _MediaButton(label: 'Foto Princ.', icon: Icons.image, file: _fotoAnuncioPrinc, onTap: () => _pickMedia('image', slot: 3)),
                  _MediaButton(label: 'Vídeo Princ.', icon: Icons.videocam, file: _videoAnuncioPrinc, onTap: () => _pickMedia('video', slot: 3)),
                ]),
                const Divider(height: 32),
                const Text('Anúncios Complementares:', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildTextField(_descAnunciosCompl, 'Texto Anúncios Complementares', maxLines: 2),
                _MediaButton(label: 'Fotos Compl.', icon: Icons.add_photo_alternate, file: _fotosAnunciosCompl.isNotEmpty ? _fotosAnunciosCompl.first : null, onTap: () => _pickMedia('image', slot: 2, multiple: true)),
              ]),

              _buildExpandableSection(titleCtrl: _titleOferta, icon: Icons.monetization_on, children: [
                _buildTextField(_descOferta, 'Descrição do Momento da Oferta', maxLines: 2),
                _MediaButton(label: 'Vídeo Oferta', icon: Icons.videocam, file: _videoOferta, onTap: () => _pickMedia('video', slot: 4)),
              ]),

              _buildExpandableSection(titleCtrl: _titleMembros, icon: Icons.groups, children: [
                _buildTextField(_nomesMembros, 'Dados/Nomes dos Membros Participantes', maxLines: 3),
                _MediaButton(label: 'Fotos Membros', icon: Icons.camera_alt, file: _fotosMembros.isNotEmpty ? _fotosMembros.first : null, onTap: () => _pickMedia('image', slot: 3, multiple: true)),
              ]),

              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
                onPressed: _publicarFicha,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('PUBLICAR FICHA COMPLETA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(children: [
      Expanded(child: DropdownButtonFormField<String>(
        value: _domingoDoMes,
        decoration: const InputDecoration(labelText: 'Culto Público', border: OutlineInputBorder()),
        items: ['1º Domingo', '2º Domingo', '3º Domingo', '4º Domingo'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
        onChanged: (v) => setState(() => _domingoDoMes = v!),
      )),
      const SizedBox(width: 12),
      Expanded(child: InkWell(
        onTap: () async {
          final p = await showDatePicker(context: context, initialDate: _dataCulto, firstDate: DateTime(2020), lastDate: DateTime.now());
          if (p != null) setState(() => _dataCulto = p);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Data do Culto', border: OutlineInputBorder()),
          child: Text(DateFormat('dd/MM/yyyy').format(_dataCulto)),
        ),
      )),
    ]);
  }

  Widget _buildExpandableSection({required TextEditingController titleCtrl, required IconData icon, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: TextFormField(
          controller: titleCtrl,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Título da Secção'),
        ),
        children: [Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children))],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    ));
  }
}

class _MediaButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final File? file;
  final VoidCallback onTap;
  const _MediaButton({required this.label, required this.icon, this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(top: 8), child: ActionChip(
      avatar: Icon(file != null ? Icons.check : icon, size: 16, color: file != null ? Colors.green : null),
      label: Text(label),
      onPressed: onTap,
    ));
  }
}