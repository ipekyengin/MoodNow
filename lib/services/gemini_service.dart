import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  /// Returns a list of 5 movie/series titles based on user input
  Future<List<String>> getMovieRecommendations(String userInput) async {
    final prompt =
        '''
You are a movie and TV series expert. Suggest 5 titles based on this mood/request:
"$userInput"

Rules:
- Return ONLY a valid JSON array of strings.
- Do NOT return markdown code blocks (like ```json ... ```), just the raw JSON.
- If the request is unclear, just suggest 5 popular diverse high-rated movies.
- Example: ["The Dark Knight", "Inception", "Friends", "Breaking Bad", "Toy Story"]
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      var text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      // Cleanup if model adds markdown despite instructions
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      final decoded = jsonDecode(text) as List;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      print('Gemini Error: $e');
      return []; // Return empty list instead of crashing
    }
  }
}

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);

  @override
  String toString() => message;
}
