import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie_model.dart';
import '../providers/library_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                movie.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: movie.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl:
                          '${AppConstants.tmdbImageBaseUrl}${movie.posterPath}',
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.grey[900]),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purpleAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purpleAccent),
                          ),
                          child: Text(
                            movie.mediaType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.purpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Overview",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Notes Section (Placeholder for now)
                    const Text(
                      "My Notes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_note, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              movie.userNote ?? "Tap to add a note...",
                              style: TextStyle(
                                color: movie.userNote != null
                                    ? Colors.white
                                    : Colors.grey,
                                fontStyle: movie.userNote != null
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: Consumer<LibraryProvider>(
        builder: (context, libProvider, _) {
          final isFav = libProvider.isFavorite(movie);
          return FloatingActionButton(
            backgroundColor: isFav ? Colors.redAccent : Colors.white,
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              final username = authProvider.currentUser?.username;
              if (username != null) {
                await libProvider.toggleFavorite(username, movie);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav ? "Removed from Favorites" : "Added to Favorites",
                      ),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please login to manage favorites"),
                  ),
                );
              }
            },
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.white : Colors.black,
            ),
          );
        },
      ),
    );
  }
}
