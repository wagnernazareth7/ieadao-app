import 'package:flutter/material.dart';
import 'package:ieadao/core/theme/app_colors.dart';
import '../../../core/models/music_model.dart';

class MusicDetailPage extends StatelessWidget {
  final Music music;
  const MusicDetailPage({super.key, required this.music});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(music.title),
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.orangeAccent,
            labelColor: Colors.orangeAccent,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'LETRA', icon: Icon(Icons.lyrics)),
              Tab(text: 'CIFRA', icon: Icon(Icons.music_note)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ABA DA LETRA
            _buildTextContent(music.lyrics, Icons.lyrics_outlined, 'Letra da Canção'),
            // ABA DA CIFRA
            _buildTextContent(music.chords, Icons.piano, 'Cifras e Acordes'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent(String content, IconData icon, String title) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            content.isEmpty ? 'Nenhuma informação registrada.' : content,
            style: TextStyle(
              fontSize: 16, 
              fontFamily: 'monospace', // Ideal para cifras (alinhamento fixo)
              height: 1.6,
              color: Colors.blueGrey.shade900
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
