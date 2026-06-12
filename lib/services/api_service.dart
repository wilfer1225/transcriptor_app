import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Endpoints oficiales de Groq compatibles con OpenAI
  static const String _audioUrl =
      'https://api.groq.com/openai/v1/audio/transcriptions';
  static const String _chatUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  // 1. Transcribir Audio (Whisper)
  static Future<String> transcribirAudio({
    required String rutaArchivo,
    required String apiKey,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(_audioUrl));

    // Headers de autenticación
    request.headers.addAll({'Authorization': 'Bearer $apiKey'});

    // Agregamos el archivo y configuramos el modelo
    request.files.add(await http.MultipartFile.fromPath('file', rutaArchivo));
    request.fields['model'] = 'whisper-large-v3';
    request.fields['response_format'] = 'json';

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse['text'];
    } else {
      throw Exception('Error en la transcripción: ${response.body}');
    }
  }

  // 2. Mejorar Texto con IA (LLaMA)
  static Future<String> mejorarTexto({
    required String textoCrudo,
    required String titulo,
    required String apiKey,
  }) async {
    final prompt =
        '''Eres un asistente experto en corrección y estructuración de transcripciones de audio.

El contexto/tema de la transcripción es: "$titulo"

Tu tarea:
1. Corregí errores ortográficos y de puntuación.
2. Separá el texto en párrafos con sentido lógico.
3. Corregí palabras que claramente fueron mal transcritas según el contexto.
4. Mantené el contenido original — no agregues ni inventes información.
5. Devolvé SOLO el texto corregido, sin explicaciones ni comentarios.

Transcripción original:
$textoCrudo''';

    final response = await http.post(
      Uri.parse(_chatUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.3,
        'max_tokens': 4096,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse['choices'][0]['message']['content'].toString().trim();
    } else {
      throw Exception('Error al mejorar con IA: ${response.body}');
    }
  }
}
