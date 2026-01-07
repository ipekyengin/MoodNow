import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';
import '../services/storage_service.dart';

class LibraryProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  Map<String, List<Movie>> _allLists = {
    'Favorites': [],
    'Movies': [],
    'Series': [],
  };

  Map<String, List<Movie>> get allLists => _allLists;

  List<Movie> get favorites => _allLists['Favorites'] ?? [];
  List<Movie> get movies => _allLists['Movies'] ?? [];
  List<Movie> get series => _allLists['Series'] ?? [];

  /// Retrieves a list by name, handling aliases like "TV Series" -> "Series"
  List<Movie> getList(String listName) {
    if (listName == 'TV Series') {
      return _allLists['Series'] ?? [];
    }
    return _allLists[listName] ?? [];
  }

  // Get custom lists (keys that are not default)
  List<String> get customListNames => _allLists.keys
      .where((k) => !['Favorites', 'Movies', 'Series'].contains(k))
      .toList();

  Future<void> loadUserLists(String username) async {
    _allLists = await _storageService.getUserLists(username);
    notifyListeners();
  }

  Future<void> _save(String username) async {
    await _storageService.saveUserLists(username, _allLists);
    notifyListeners();
  }

  // Add a movie to a list
  Future<void> addToList(String username, Movie movie, String listName) async {
    if (!_allLists.containsKey(listName)) {
      _allLists[listName] = [];
    }

    // Check if already in list
    if (!_allLists[listName]!.any((m) => m.id == movie.id)) {
      final movieToAdd = movie;
      movieToAdd.listName = listName;
      if (listName == 'Favorites') movieToAdd.isFavorite = true;

      _allLists[listName]!.add(movieToAdd);

      // Auto-categorize
      if (listName != 'Movies' && listName != 'Series') {
        _addToAutoCategory(movie);
      }

      await _save(username);
    }
  }

  void _addToAutoCategory(Movie movie) {
    if (movie.mediaType == 'tv') {
      if (!_allLists['Series']!.any((m) => m.id == movie.id)) {
        _allLists['Series']!.add(movie);
      }
    } else {
      // Default to movies if not explicitly TV
      if (!_allLists['Movies']!.any((m) => m.id == movie.id)) {
        _allLists['Movies']!.add(movie);
      }
    }
  }

  Future<void> removeFromList(
    String username,
    Movie movie,
    String listName,
  ) async {
    if (_allLists.containsKey(listName)) {
      _allLists[listName]!.removeWhere((m) => m.id == movie.id);
      if (listName == 'Favorites') {
        // We might want to update the isFavorite flag in other lists too,
        // but for now simplistic approach
      }
      await _save(username);
    }
  }

  Future<void> toggleFavorite(String username, Movie movie) async {
    final isFav = _allLists['Favorites']!.any((m) => m.id == movie.id);
    if (isFav) {
      await removeFromList(username, movie, 'Favorites');
      movie.isFavorite = false;
    } else {
      await addToList(username, movie, 'Favorites');
      movie.isFavorite = true;
    }
    // Also ensure auto-cat
    _addToAutoCategory(movie);
    await _save(username);
  }

  Future<void> createCustomList(String username, String listName) async {
    if (!_allLists.containsKey(listName)) {
      _allLists[listName] = [];
      await _save(username);
    }
  }

  Future<void> deleteCustomList(String username, String listName) async {
    if (_allLists.containsKey(listName)) {
      _allLists.remove(listName);
      await _save(username);
    }
  }

  bool isFavorite(Movie movie) {
    return _allLists['Favorites']?.any((m) => m.id == movie.id) ?? false;
  }
}
