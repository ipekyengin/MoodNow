import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/gemini_service.dart';
import '../services/tmdb_service.dart';

class MoodProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final TmdbService _tmdbService = TmdbService();

  List<String> _pendingTitles = [];
  Movie? _currentMovie;
  bool _isLoading = false;
  String? _error;

  Movie? get currentMovie => _currentMovie;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> findMovies(String mood) async {
    _isLoading = true;
    _error = null;
    _currentMovie = null;
    _pendingTitles = [];
    notifyListeners();

    try {
      // 1. Get titles from Gemini
      final titles = await _geminiService.getMovieRecommendations(mood);
      if (titles.isEmpty) {
        _error = "Couldn't find any recommendations. Try a different mood.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      _pendingTitles = titles;

      // 2. Fetch the first movie immediately
      await nextMovie();
    } on GeminiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = "An unexpected error occurred. Please try again.";
      debugPrint('Unexpected error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> nextMovie() async {
    if (_pendingTitles.isEmpty) {
      _currentMovie = null;
      _error = "No more recommendations. Try searching again!";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch details for the next title in the list
      // We loop until we find a valid movie or run out of titles
      while (_pendingTitles.isNotEmpty) {
        final title = _pendingTitles.removeAt(0);
        final movie = await _tmdbService.searchMovie(title);

        if (movie != null) {
          _currentMovie = movie;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // If we exit the loop, we ran out of titles without finding a match
      _currentMovie = null;
      _error = "No details found for the remaining recommendations.";
    } catch (e) {
      _error = "Error fetching movie details: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
