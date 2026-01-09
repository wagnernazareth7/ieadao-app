import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/culto_highlight_service.dart';
import '../models/culto_highlight_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/audio_player_widget.dart'; // Import do novo player

class MuralPage extends ConsumerWidget {
  const MuralPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = CultoHighlightService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mural da Igreja'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<CultoHighlight>>(
        stream: service.watchHighlights(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('O mural está vazio. Aguarde os próximos cultos!'));
          }

          final destaques = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: destaques.length,
            itemBuilder: (context, index) {
              final item = destaques[index];
              return _MuralCard(highlight: item);
            },
          );
        },
      ),
    );
  }
}

class _MuralCard extends StatelessWidget {
  final CultoHighlight highlight;
  const _MuralCard({required this.highlight});

  @override
  Widget build(BuildContext context) {
    final content = highlight.content;
    final dateStr = DateFormat('dd/MM/yyyy').format(highlight.data);

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CABEÇALHO
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withOpacity(0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(highlight.domingoDoMes.toUpperCase(), 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12, letterSpacing: 1.2)),
                    Text('Culto de $dateStr', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Icon(Icons.church, color: AppColors.primary, size: 20),
              ],
            ),
          ),

          // 2. MOMENTO DA PALAVRA (Com Player de Áudio)
          if (content['palavra'] != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(content['palavra']['titulo'] ?? 'A Palavra'),
                  const SizedBox(height: 12),
                  if (content['palavra']['foto_preg'] != null)
                    _buildHeroImage(content['palavra']['foto_preg']),
                  const SizedBox(height: 16),
                  Text('Ministração por: ${content['palavra']['pregador']}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(content['palavra']['descricao'] ?? '', style: const TextStyle(color: Colors.black87, height: 1.4)),
                  
                  // INTEGRAÇÃO DO PLAYER DE ÁUDIO REAL
                  if (content['palavra']['audio'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: AudioPlayerWidget(
                        url: content['palavra']['audio'], 
                        title: 'Ouvir Pregação Completa',
                      ),
                    ),
                ],
              ),
            ),

          // 3. GALERIA DO LOUVOR
          if (content['louvor'] != null && (content['louvor']['fotos'] as List).isNotEmpty)
            _buildGallery(content['louvor']['titulo'] ?? 'Louvor', content['louvor']['fotos']),

          // 4. ANÚNCIOS E VÍDEOS
          if (content['louvor']?['video'] != null || content['oferta']?['video'] != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (content['louvor']?['video'] != null)
                    _ActionBadge(icon: Icons.videocam, label: 'Vídeo Louvor', color: Colors.blue),
                  if (content['oferta']?['video'] != null)
                    _ActionBadge(icon: Icons.volunteer_activism, label: 'Vídeo Oferta', color: Colors.teal),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1));
  }

  Widget _buildHeroImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator())),
      ),
    );
  }

  Widget _buildGallery(String title, List<dynamic> urls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: _buildSectionTitle(title)),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: urls.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: urls[i],
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ActionBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
