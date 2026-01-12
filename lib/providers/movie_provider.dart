import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';

class MovieProvider with ChangeNotifier {
  final TmdbService _tmdbService = TmdbService();

  Movie? _heroMovie;
  List<Movie> _trendingMovies = [];
  List<Movie> _popularTVSeries = [];

  bool _isLoading = false;
  String? _error;

  Movie? get heroMovie => _heroMovie;
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get popularTVSeries => _popularTVSeries;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHomeScreenData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all data in parallel for performance
      final results = await Future.wait([
        _tmdbService.getTrendingAllDaily(),
        _tmdbService.getTrendingMoviesDaily(),
        _tmdbService.getPopularTVSeries(),
      ]);

      final trendingAll = results[0];
      final trendingMovies = results[1];
      final popularTV = results[2];

      // 1. Set Hero Movie (first item from trending all)
      if (trendingAll.isNotEmpty) {
        _heroMovie = trendingAll.first;
      }

      // 2. Set Trending Movies
      if (trendingMovies.isNotEmpty) {
        _trendingMovies = trendingMovies;
      }

      // 3. Set Popular TV Series
      if (popularTV.isNotEmpty) {
        _popularTVSeries = popularTV;
      }
    } catch (e) {
      _error = "Failed to load movies. Please check your internet connection.";
      debugPrint("MovieProvider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void retry() {
    loadHomeScreenData();
  }
}
