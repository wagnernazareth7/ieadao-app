import 'package:cloud_firestore/cloud_firestore.dart';

class Music {
  final String id;
  final String title;
  final String composer;
  final String lyrics; // Letra da música
  final String chords; // NOVO: Cifras/Acordes
  final String? youtubeUrl;
  final DateTime createdAt;

  Music({
    required this.id,
    required this.title,
    required this.composer,
    required this.lyrics,
    required this.chords,
    this.youtubeUrl,
    required this.createdAt,
  });

  factory Music.fromMap(String id, Map<String, dynamic> map) {
    return Music(
      id: id,
      title: map['title'] ?? '',
      composer: map['composer'] ?? '',
      lyrics: map['lyrics'] ?? '',
      chords: map['chords'] ?? '',
      youtubeUrl: map['youtubeUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'composer': composer,
      'lyrics': lyrics,
      'chords': chords,
      'youtubeUrl': youtubeUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
