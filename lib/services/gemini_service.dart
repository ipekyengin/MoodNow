import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  /// 🔑 MoodProvider'ın çağırdığı METOT
  Future<List<String>> getMovieRecommendations(String userInput) async {
    final prompt =
        '''
Suggest 5 movie or TV series titles based on this input:
"$userInput"

Rules:
- Return ONLY a valid JSON array
- No markdown
- No explanations

Example:
["Inception", "The Matrix", "Interstellar"]
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      final decoded = jsonDecode(text) as List;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      throw GeminiException('Gemini response parsing failed: $e');
    }
  }
}

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);

  @override
  String toString() => message;
}
