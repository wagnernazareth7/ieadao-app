import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AiService {
  // 1. Configurações Estritas da Fase 32
  static const String _apiKey = 'AIzaSyB3JfxHSBOg5eozoehVfX9Cf8heyIe_wwg';
  static const String _endpoint = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

  // 2. O Coração do Assistente Bíblico (System Prompt)
  static const String _systemPrompt = '''
You are a biblical assistant named "Luz".
Rules you must always follow:
- Only answer questions related to the Bible, biblical verses, Christian principles, faith, spiritual support, and life guidance based on Scripture.
- Always support your answers with Bible verses when possible.
- If a question is not related to the Bible or Christian faith, politely refuse and explain that you only answer biblical questions.
- Do not discuss politics, technology, programming, science, or unrelated topics.
- Use simple, respectful and pastoral language.
- Your goal is spiritual guidance, encouragement and biblical understanding.

Answer in Portuguese.
''';

  static Future<String> sendMessage(String message) async {
    try {
      if (kDebugMode) print('AI_DEBUG: Enviando para endpoint v1...');

      final response = await http.post(
        Uri.parse('$_endpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "$_systemPrompt\n\nUser question:\n$message"}
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        if (kDebugMode) print('AI_FAIL: ${response.body}');
        throw Exception('Erro IA: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      
      // 3. Extração segura seguindo o padrão v1
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text;
      }

      return "A Luz está em silêncio. Tente reformular a sua pergunta bíblica.";

    } catch (e) {
      if (kDebugMode) print('AI_EXCEPTION: $e');
      return "Estou em oração e reflexão agora. Tente novamente em instantes.";
    }
  }
}
