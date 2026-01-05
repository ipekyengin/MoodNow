import 'dart:io';
import 'dart:convert';

void main() async {
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('Error: .env file not found');
    exit(1);
  }

  final lines = await envFile.readAsLines();
  String? apiKey;
  for (var line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.split('=')[1].trim();
      break;
    }
  }

  if (apiKey == null) {
    print('Error: GEMINI_API_KEY not found');
    exit(1);
  }

  print('Listing models using raw HTTP...');
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
  );
  final client = HttpClient();

  try {
    final request = await client.getUrl(url);
    final response = await request.close();

    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final json = jsonDecode(responseBody);
      final models = json['models'] as List;
      print('Found ${models.length} models:');
      for (var model in models) {
        print('- ${model['name']} (${model['displayName']})');
      }
    } else {
      print('Error: ${response.statusCode}');
      print('Body: $responseBody');
    }
  } catch (e) {
    print('Exception: $e');
  } finally {
    client.close();
  }
}
