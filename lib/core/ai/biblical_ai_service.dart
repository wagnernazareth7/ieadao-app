import 'dart:convert';
import 'package:http/http.dart' as http;

class BiblicalAIService {
  // Chave de API Hugging Face ( Wagner N. Tembe )
  static const String _apiKey = 'hf_aBRnuqvtUWhcZnwZgGpOZfzmsuFKDACIF';
  
  // Modelo recomendado: Mistral-7B-Instruct
  static const String _model = 'mistralai/Mistral-7B-Instruct-v0.2';

  static const String _systemPrompt = '''
You are a biblical assistant named "Luz".

Rules you must always follow:
- Only answer questions related to the Bible, biblical verses, Christian principles, faith, spiritual support, sustainability and life guidance based on Scripture.
- Always support your answers with Bible verses when possible.
- If a question is not related to the Bible or Christian faith, politely refuse and explain that you only answer biblical questions.
- Do not discuss politics, technology, programming, science, or unrelated topics.
- Use simple, respectful and pastoral language.
- Your goal is spiritual guidance, encouragement and biblical understanding.

Answer in Portuguese.
''';

  static Future<String> ask(String userQuestion) async {
    final uri = Uri.parse(
      'https://api-inference.huggingface.co/models/$_model',
    );

    final fullPrompt = '''
$_systemPrompt

User question:
$userQuestion
''';

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': fullPrompt,
        'parameters': {
          'max_new_tokens': 500,
          'temperature': 0.4,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro na conexão espiritual: ${response.body}');
    }

    final data = jsonDecode(response.body);
    
    // O Mistral no Hugging Face devolve o texto gerado incluindo o prompt, 
    // por isso limpamos para mostrar apenas a resposta.
    String generatedText = data[0]['generated_text'];
    return generatedText.replaceFirst(fullPrompt, '').trim();
  }
}
