import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  // Read API Key from .env manually to avoid flutter_dotenv dependency issues in standalone script
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('Error: .env file not found');
    return;
  }

  final lines = await envFile.readAsLines();
  String? apiKey;
  for (var line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.split('=')[1].trim();
      break;
    }
  }

  if (apiKey == null || apiKey.isEmpty) {
    print('Error: GEMINI_API_KEY not found in .env');
    return;
  }

  print('Using API Key: ${apiKey.substring(0, 5)}...');

  final model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: apiKey,
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  final prompt = '''
      Suggest 5-10 movie or TV series titles that match this mood: "Happy".
      Return ONLY a valid JSON list of strings. Do not include any markdown formatting (like ```json).
      Example: ["The Matrix", "Inception", "Dark"]
    ''';

  try {
    print('Sending request to Gemini (gemini-1.5-flash)...');
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    print('Response received:');
    print(response.text);

    if (response.text == null) {
      print('Response text is null');
      return;
    }

    String jsonText = response.text!.trim();
    if (jsonText.startsWith('```json')) {
      jsonText = jsonText.replaceAll('```json', '').replaceAll('```', '');
    } else if (jsonText.startsWith('```')) {
      jsonText = jsonText.replaceAll('```', '');
    }

    print('Parsed JSON text: $jsonText');

    final List<dynamic> jsonList = jsonDecode(jsonText);
    print('Successfully decoded JSON list: $jsonList');
  } catch (e) {
    print('Gemini API Error details: $e');
  }
}
