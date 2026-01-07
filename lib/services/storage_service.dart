import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_model.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _usersKey = 'users_db_v1';
  static const String _sessionKey = 'current_session_user';
  // user_lists prefix: user_lists_<username>

  // --- Auth & Users ---

  Future<void> registerUser(User user) async {
    final users = await getAllUsers();
    if (users.containsKey(user.username)) {
      throw Exception('Username already exists');
    }
    users[user.username] = user;
    await _saveAllUsers(users);
  }

  Future<User?> loginUser(String username, String password) async {
    final users = await getAllUsers();
    final user = users[username];
    if (user != null && user.password == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, username);
      return user;
    }
    return null;
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<String?> getCurrentSessionUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<Map<String, User>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_usersKey);
    if (data == null) return {};

    final Map<String, dynamic> jsonMap = jsonDecode(data);
    return jsonMap.map((key, value) => MapEntry(key, User.fromJson(value)));
  }

  Future<void> _saveAllUsers(Map<String, User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(
      users.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString(_usersKey, data);
  }

  // --- Lists & Favorites ---

  String _getUserListsKey(String username) => 'user_lists_$username';

  Future<void> saveUserLists(
    String username,
    Map<String, List<Movie>> lists,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    // lists map: "Favorites": [Movie...], "My Custom List": [Movie...]
    final Map<String, dynamic> serializedWithJson = lists.map(
      (key, value) => MapEntry(key, value.map((m) => m.toJson()).toList()),
    );
    await prefs.setString(
      _getUserListsKey(username),
      jsonEncode(serializedWithJson),
    );
  }

  Future<Map<String, List<Movie>>> getUserLists(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_getUserListsKey(username));

    // Default structure if empty
    final Map<String, List<Movie>> defaultLists = {
      'Favorites': [],
      'Movies': [], // For auto-categorization
      'Series': [], // For auto-categorization
    };

    if (data == null) return defaultLists;

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(data);
      final Map<String, List<Movie>> loadedLists = {};

      jsonMap.forEach((key, value) {
        if (value is List) {
          loadedLists[key] = value.map((e) => Movie.fromJson(e)).toList();
        }
      });

      // Ensure defaults exist if not present
      if (!loadedLists.containsKey('Favorites')) loadedLists['Favorites'] = [];
      if (!loadedLists.containsKey('Movies')) loadedLists['Movies'] = [];
      if (!loadedLists.containsKey('Series')) loadedLists['Series'] = [];

      return loadedLists;
    } catch (e) {
      return defaultLists;
    }
  }
}
