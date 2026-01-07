import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie_model.dart';
import '../utils/constants.dart';

class TmdbService {
  final Dio _dio = Dio();
  final String? _apiKey = dotenv.env['TMDB_API_KEY'];

  Future<List<Movie>> searchMoviesAndSeries(String query) async {
    if (_apiKey == null) throw Exception('TMDB_API_KEY not found');
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        '${AppConstants.tmdbBaseUrl}/search/multi',
        queryParameters: {
          'api_key': _apiKey,
          'query': query,
          'language': 'en-US',
          'page': 1,
          'include_adult': false,
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results
            .where((item) {
              final mediaType = item['media_type'];
              final hasPoster = item['poster_path'] != null;
              // Ensure we only process 'movie' or 'tv' types
              return (mediaType == 'movie' || mediaType == 'tv') && hasPoster;
            })
            .map((item) => Movie.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('TMDB Search Error: $e');
      return [];
    }
  }

  // Used by Gemini Service to find a specific title's details
  Future<Movie?> searchBestMatch(String title) async {
    final results = await searchMoviesAndSeries(title);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
