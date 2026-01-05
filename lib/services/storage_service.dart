import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_model.dart';

class StorageService {
  static const String _watchlistKey = 'watchlist_v1';

  Future<void> saveWatchlist(List<Movie> movies) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(movies.map((m) => m.toJson()).toList());
    await prefs.setString(_watchlistKey, data);
  }

  Future<List<Movie>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_watchlistKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => Movie.fromJson(e)).toList();
  }
}
