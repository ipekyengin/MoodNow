import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../models/movie_model.dart';
import 'movie_detail_screen.dart';
import 'library_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final libraryProvider = Provider.of<LibraryProvider>(context);

    // Prepare lists
    final movies = libraryProvider.movies;
    final series = libraryProvider.series;
    final favorites = libraryProvider.favorites;

    // Check for "Watchlist" or "İzlenecekler"
    List<Movie> watchlist = [];
    if (libraryProvider.allLists.containsKey('Watchlist')) {
      watchlist = libraryProvider.allLists['Watchlist']!;
    } else if (libraryProvider.allLists.containsKey('İzlenecekler')) {
      watchlist = libraryProvider.allLists['İzlenecekler']!;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Color(0xFFE50914)),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section: Profile Info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      borderRadius: BorderRadius.circular(4),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://upload.wikimedia.org/wikipedia/commons/0/0b/Netflix-avatar.png",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? 'ipek', // Default to ipek
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Member since 2024",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Horizontal Lists
            // Pass the internal list KEY to the builder for delete logic
            _buildHorizontalList(context, "TV Series", series, "Series"),
            _buildHorizontalList(context, "Movies", movies, "Movies"),
            _buildHorizontalList(context, "Favorites", favorites, "Favorites"),
            _buildHorizontalList(context, "Watchlist", watchlist, "Watchlist"),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(
    BuildContext context,
    String title,
    List<Movie> items,
    String listKey, // Internal key for deletion
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          LibraryDetailScreen(title: title, items: items),
                    ),
                  );
                },
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),

        // List
        SizedBox(
          height: 160,
          child: items.isEmpty
              ? Center(
                  child: Text(
                    "No items in $title",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final movie = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                      onLongPress: () {
                        _showDeleteDialog(context, movie, listKey, title);
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 110,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(
                                image: NetworkImage(
                                  "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: movie.posterPath == null
                                ? Container(
                                    color: Colors.grey[800],
                                    alignment: Alignment.center,
                                    child: Text(
                                      movie.title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          // Optional Overlay Hint (or just rely on long press)
                        ],
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Movie movie,
    String listKey,
    String displayTitle,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Remove from List?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Do you want to remove '${movie.title}' from $displayTitle?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              final libProvider = Provider.of<LibraryProvider>(
                context,
                listen: false,
              );
              final username = authProvider.currentUser?.username;

              if (username != null) {
                await libProvider.removeFromList(username, movie, listKey);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Removed from $displayTitle"),
                      backgroundColor: const Color(0xFFE50914),
                    ),
                  );
                }
              }
            },
            child: const Text(
              "Remove",
              style: TextStyle(color: Color(0xFFE50914)),
            ),
          ),
        ],
      ),
    );
  }
}
