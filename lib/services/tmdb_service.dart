import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie_model.dart';
import '../utils/constants.dart';

class TmdbService {
  final Dio _dio = Dio();
  final String? _apiKey = dotenv.env['TMDB_API_KEY'];

  Future<Movie?> searchMovie(String title) async {
    if (_apiKey == null) throw Exception('TMDB_API_KEY not found');

    try {
      final response = await _dio.get(
        '${AppConstants.tmdbBaseUrl}/search/multi',
        queryParameters: {
          'api_key': _apiKey,
          'query': title,
          'language': 'en-US', // Or make it configurable
          'page': 1,
        },
      );

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        if (results.isNotEmpty) {
          // Filter out people, only keep movies or tv shows with posters ideally
          final movieData = results.firstWhere(
            (item) =>
                item['media_type'] != 'person' && item['poster_path'] != null,
            orElse: () => null,
          );

          if (movieData != null) {
            // Adjust title/name field (TMDB uses 'name' for TV, 'title' for Movie)
            movieData['title'] = movieData['title'] ?? movieData['name'];
            return Movie.fromJson(movieData);
          }
        }
      }
      return null;
    } catch (e) {
      print('TMDB Search Error: $e');
      return null; // Don't crash, just return null if not found
    }
  }
}
