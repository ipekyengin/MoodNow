import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, libProvider, _) {
          final favorites = libProvider.favorites;
          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                'No favorites yet. ❤️',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final movie = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: movie.posterPath != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.movie, size: 50),
                        )
                      : const Icon(Icons.movie, size: 50),
                  title: Text(movie.title),
                  subtitle: Text(
                    '${movie.mediaType.toUpperCase()} • ${movie.voteAverage.toStringAsFixed(1)} ★',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      // Remove from favorites
                      // Ideally we need username here.
                      // Check main for how to access username or store it in LibraryProvider
                      // For now, let's assume LibraryProvider caches username or we get it from Auth
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
