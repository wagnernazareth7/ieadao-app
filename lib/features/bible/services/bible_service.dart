import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_model.dart';

class BibleService {
  /// Simula a busca de versículos (Poderia ler de um JSON em assets)
  Future<List<BibleVerse>> getDailyVerses() async {
    // Por enquanto, usaremos versículos semente (Seed Data) para o Offline imediato
    return [
      BibleVerse(book: 'Salmos', chapter: 23, verse: 1, text: 'O Senhor é o meu pastor, nada me faltará.'),
      BibleVerse(book: 'João', chapter: 3, verse: 16, text: 'Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito.'),
      BibleVerse(book: 'Filipenses', chapter: 4, verse: 13, text: 'Tudo posso naquele que me fortalece.'),
      BibleVerse(book: 'Josué', chapter: 1, verse: 9, text: 'Não to mandei eu? Esforça-te, e tem bom ânimo.'),
    ];
  }

  /// Busca um capítulo completo (Ex: João 1)
  Future<List<BibleVerse>> getChapter(String book, int chapter) async {
    // Aqui implementaremos a leitura do JSON estático
    return [];
  }
}
