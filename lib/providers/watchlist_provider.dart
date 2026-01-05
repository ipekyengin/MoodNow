import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/storage_service.dart';

class WatchlistProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Movie> _watchlist = [];

  List<Movie> get watchlist => _watchlist;

  WatchlistProvider() {
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    _watchlist = await _storageService.getWatchlist();
    notifyListeners();
  }

  Future<void> addToWatchlist(Movie movie) async {
    // Avoid duplicates
    if (!_watchlist.any((m) => m.id == movie.id)) {
      _watchlist.add(movie);
      // Move new items to the top? Or bottom. Let's append to bottom for now.
      await _save();
    }
  }

  Future<void> removeFromWatchlist(int id) async {
    _watchlist.removeWhere((m) => m.id == id);
    await _save();
  }

  Future<void> updateNote(int id, String note) async {
    final index = _watchlist.indexWhere((m) => m.id == id);
    if (index != -1) {
      _watchlist[index].userNote = note;
      await _save();
    }
  }

  Future<void> _save() async {
    await _storageService.saveWatchlist(_watchlist);
    notifyListeners();
  }
}
